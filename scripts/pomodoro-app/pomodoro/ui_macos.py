"""The macOS frontend: a menu bar item driven by `core.Pomodoro`."""

import subprocess
from dataclasses import replace

import rumps
from AppKit import (NSAlert, NSAlertFirstButtonReturn, NSApp,
                    NSAttributedString, NSColor, NSFont, NSFontAttributeName,
                    NSForegroundColorAttributeName, NSMakeRect,
                    NSTextAlignmentRight, NSTextField, NSView)

from . import core
from .core import Action, Config, Phase, Pomodoro

ICONS = {
    Phase.IDLE: '🍅',
    Phase.SESSION: '🍅',
    Phase.SESSION_DONE: '🍅',
    Phase.BREAK: '☕️',
    Phase.BREAK_DONE: '☕️',
    Phase.FINISHED: '🍅',
}


# -- notifications --------------------------------------------------------

class MacNotifier:
    def send(self, title: str, message: str) -> None:
        try:
            rumps.notification(title, None, message)
        except Exception:
            # rumps needs a real bundle identifier for this; fall back to the
            # same osascript call the old CLI used when running unbundled.
            body = message.replace('"', '\\"')
            summary = title.replace('"', '\\"')
            subprocess.run(
                ['osascript', '-e',
                 f'display notification "{body}" with title "{summary}"'],
                check=False)


# -- the setup form -------------------------------------------------------

LABEL_WIDTH = 116
FIELD_WIDTH = 190
ROW_HEIGHT = 24
ROW_GAP = 10


def _static_label(text: str, y: float) -> NSTextField:
    label = NSTextField.alloc().initWithFrame_(
        NSMakeRect(0, y - 3, LABEL_WIDTH, ROW_HEIGHT))
    label.setStringValue_(text)
    label.setBezeled_(False)
    label.setDrawsBackground_(False)
    label.setEditable_(False)
    label.setSelectable_(False)
    label.setAlignment_(NSTextAlignmentRight)
    return label


def _input_field(value: str, y: float) -> NSTextField:
    field = NSTextField.alloc().initWithFrame_(
        NSMakeRect(LABEL_WIDTH + ROW_GAP, y, FIELD_WIDTH, ROW_HEIGHT))
    field.setStringValue_(value)
    return field


def _text(field: NSTextField) -> str:
    return str(field.stringValue()).strip()


def _as_int(field: NSTextField, fallback: int) -> int:
    try:
        return int(_text(field))
    except ValueError:
        return fallback


def _as_duration(field: NSTextField, fallback: int) -> int:
    return core.parse_duration(_text(field)) or fallback


def prompt_config(defaults: Config) -> Config | None:
    """Ask for the intent and the three lengths. None means cancelled."""
    rows = [
        ('Intent:', defaults.intent),
        ('Sessions:', str(defaults.sessions)),
        ('Session length:', core.format_duration(defaults.session_seconds)),
        ('Break length:', core.format_duration(defaults.break_seconds)),
    ]
    height = len(rows) * ROW_HEIGHT + (len(rows) - 1) * ROW_GAP
    form = NSView.alloc().initWithFrame_(
        NSMakeRect(0, 0, LABEL_WIDTH + ROW_GAP + FIELD_WIDTH, height))

    fields = []
    for index, (caption, value) in enumerate(rows):
        # AppKit's origin is bottom left, so the first row sits highest.
        y = height - (index + 1) * ROW_HEIGHT - index * ROW_GAP
        form.addSubview_(_static_label(caption, y))
        field = _input_field(value, y)
        form.addSubview_(field)
        fields.append(field)

    for field, following in zip(fields, fields[1:] + fields[:1]):
        field.setNextKeyView_(following)
    intent, sessions, session_length, break_length = fields

    alert = NSAlert.alloc().init()
    alert.setMessageText_('Start a pomodoro')
    alert.addButtonWithTitle_('Start')
    alert.addButtonWithTitle_('Cancel')
    alert.setAccessoryView_(form)
    alert.window().setInitialFirstResponder_(intent)

    # Without this the dialog opens behind whatever has focus, because the app
    # is an LSUIElement agent and never becomes active on its own.
    NSApp.activateIgnoringOtherApps_(True)
    if alert.runModal() != NSAlertFirstButtonReturn:
        return None

    return Config(
        intent=_text(intent),
        sessions=_as_int(sessions, defaults.sessions),
        session_seconds=_as_duration(session_length, defaults.session_seconds),
        break_seconds=_as_duration(break_length, defaults.break_seconds),
    ).sanitized()


# -- the menu bar app -----------------------------------------------------

class PomodoroApp(rumps.App):
    def __init__(self, pomodoro: Pomodoro, notifier: MacNotifier):
        super().__init__('Pomodoro', title='🍅 ready', quit_button='Quit')
        self._pomodoro = pomodoro
        self._notifier = notifier

        # Every item exists from the start and is hidden when the phase has no
        # use for it, so the menu only ever shows what can actually be clicked.
        self._items = {
            Action.START: rumps.MenuItem('Start new timer…', self._on_start),
            Action.GATE: rumps.MenuItem('Start break', self._on_gate),
        }
        self.menu = list(self._items.values())

        self._ticker = rumps.Timer(self._on_tick, 1)
        # Fired once, just after the run loop starts: the status item has to
        # exist before a modal dialog can be put on top of it.
        self._opening = rumps.Timer(self._on_launch, 0.1)

    def run(self) -> None:
        self._ticker.start()
        self._opening.start()
        super().run()

    # -- painting ---------------------------------------------------------

    def _set_title(self, text: str, urgent: bool) -> None:
        """Set the menu bar title, in red when the timer wants attention.

        rumps' own `title` only takes a plain string, so this reaches through to
        the NSStatusItem's button and sets an attributed string instead. The
        monospaced digits stop the clock from jittering as the numbers change.
        Private rumps internals, hence the fallback to the plain title.
        """
        try:
            size = NSFont.menuBarFontOfSize_(0).pointSize()
            attributes = {
                NSFontAttributeName:
                    NSFont.monospacedDigitSystemFontOfSize_weight_(size, 0),
                NSForegroundColorAttributeName:
                    NSColor.systemRedColor() if urgent else NSColor.labelColor(),
            }
            attributed = NSAttributedString.alloc().initWithString_attributes_(
                text, attributes)
            self._nsapp.nsstatusitem.button().setAttributedTitle_(attributed)
        except Exception:
            self.title = text

    def _render(self) -> None:
        view = self._pomodoro.view()
        parts = [ICONS[view.phase]]
        if view.label:
            parts.append(view.label)
        if view.overrun:
            parts.append(view.overrun)
        if view.detail:
            parts.append(f'· {view.detail}')
        self._set_title(' '.join(parts), view.urgent)

        offered = {spec.action: spec.title for spec in view.actions}
        for action, item in self._items.items():
            title = offered.get(action)
            item.hidden = title is None
            if title is not None:
                item.title = title

    # -- callbacks --------------------------------------------------------

    def _on_tick(self, _) -> None:
        event = self._pomodoro.tick()
        if event is not None:
            self._notifier.send(*core.notification_for(event, self._pomodoro))
        self._render()

    def _on_launch(self, timer) -> None:
        timer.stop()
        self._render()
        self._on_start(None)

    def _on_start(self, _) -> None:
        # Keep the lengths from last time, but always ask for a fresh intent.
        config = prompt_config(replace(self._pomodoro.config, intent=''))
        if config is None:
            return
        self._pomodoro.start(config)
        self._render()

    def _on_gate(self, _) -> None:
        self._pomodoro.advance()
        self._render()


def main() -> None:
    PomodoroApp(Pomodoro(), MacNotifier()).run()

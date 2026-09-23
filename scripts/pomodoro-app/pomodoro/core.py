"""The pomodoro state machine.

Deliberately free of UI and platform imports: everything here is state plus an
injected clock. A frontend drives it by calling the commands and rendering
`view()`, which is the only thing it needs to understand -- including which
menu entries to offer, so a rofi frontend can show the same list.

The remaining time is derived from a deadline rather than counted down tick by
tick, so a missed timer fire -- or the laptop lid being closed -- does not make
a 25 minute session take 27 minutes.
"""

import math
import re
import time
from collections.abc import Callable
from dataclasses import dataclass, replace
from enum import Enum, auto


class Phase(Enum):
    IDLE = auto()
    SESSION = auto()
    SESSION_DONE = auto()  # waiting for the user to start the break
    BREAK = auto()
    BREAK_DONE = auto()  # waiting for the user to start the next session
    FINISHED = auto()


#: Phases that count down on their own.
TIMED = frozenset({Phase.SESSION, Phase.BREAK})
#: Phases that sit still until the user clicks the menu.
GATES = frozenset({Phase.SESSION_DONE, Phase.BREAK_DONE})


class Event(Enum):
    SESSION_ENDED = auto()
    BREAK_ENDED = auto()
    FINISHED = auto()


class Action(Enum):
    """A command a frontend may offer. Which ones depends on the phase."""

    START = auto()
    GATE = auto()


# -- durations ------------------------------------------------------------

_UNITS = {
    's': 1, 'sec': 1, 'secs': 1, 'second': 1, 'seconds': 1,
    'm': 60, 'min': 60, 'mins': 60, 'minute': 60, 'minutes': 60,
    'h': 3600, 'hr': 3600, 'hrs': 3600, 'hour': 3600, 'hours': 3600,
}
_PART = re.compile(r'(\d+)([a-z]*)')


def parse_duration(text: str) -> int | None:
    """Read '25min', '1s' or '1h30m' as seconds. A bare number means minutes.

    Returns None for anything unparseable, which lets a caller fall back to
    whatever default it had.
    """
    cleaned = re.sub(r'\s+', '', text.strip().lower())
    total = 0
    position = 0
    for match in _PART.finditer(cleaned):
        if match.start() != position:  # a gap means we did not understand it
            return None
        position = match.end()
        amount, unit = match.groups()
        if unit and unit not in _UNITS:
            return None
        total += int(amount) * _UNITS.get(unit, 60)
    if position != len(cleaned):
        return None
    return total or None


def format_duration(seconds: int) -> str:
    """The inverse of `parse_duration`, for prefilling an input field."""
    if seconds >= 3600 and seconds % 3600 == 0:
        return f'{seconds // 3600}h'
    if seconds % 60 == 0:
        return f'{seconds // 60}min'
    return f'{seconds}s'


def format_clock(seconds: float) -> str:
    """Format as MM:SS, rounding up so a fresh 25 minute timer reads 25:00."""
    total = math.ceil(max(0.0, seconds))
    return f'{total // 60:02d}:{total % 60:02d}'


# -- configuration and rendering ------------------------------------------

@dataclass(frozen=True)
class Config:
    intent: str = ''
    sessions: int = 4
    session_seconds: int = 25 * 60
    break_seconds: int = 5 * 60

    def sanitized(self) -> 'Config':
        """Clamp whatever the form handed us into something runnable."""
        return replace(
            self,
            intent=self.intent.strip(),
            sessions=max(1, self.sessions),
            session_seconds=max(1, self.session_seconds),
            break_seconds=max(1, self.break_seconds),
        )


@dataclass(frozen=True)
class MenuAction:
    action: Action
    title: str


@dataclass(frozen=True)
class View:
    """Everything a frontend needs to draw, with no logic left to redo."""

    phase: Phase
    label: str | None  # '12:34' while a timer runs, a short word otherwise
    detail: str | None  # the counter and intent, shown next to the label
    overrun: str | None  # '-00:42' once a gate has been left waiting
    urgent: bool
    actions: tuple[MenuAction, ...]


INTENT_LIMIT = 24


def _shorten(text: str, limit: int = INTENT_LIMIT) -> str:
    """Keep the menu bar from growing without bound."""
    return text if len(text) <= limit else text[:limit - 1].rstrip() + '…'


class Pomodoro:
    def __init__(self, clock: Callable[[], float] = time.monotonic):
        self._clock = clock
        self.config = Config()
        self.phase = Phase.IDLE
        self.session = 0
        self._ends_at: float | None = None
        self._gate_since: float | None = None

    # -- queries ----------------------------------------------------------

    @property
    def remaining(self) -> float:
        if self._ends_at is None:
            return 0.0
        return max(0.0, self._ends_at - self._clock())

    @property
    def overrun(self) -> float:
        """How long a finished phase has been waiting to be acknowledged."""
        if self._gate_since is None:
            return 0.0
        return max(0.0, self._clock() - self._gate_since)

    # -- commands ---------------------------------------------------------

    def start(self, config: Config) -> None:
        self.config = config.sanitized()
        self.session = 1
        self._begin(Phase.SESSION, self.config.session_seconds)

    def advance(self) -> None:
        """Walk through a gate into the phase waiting behind it."""
        if self.phase is Phase.SESSION_DONE:
            self._begin(Phase.BREAK, self.config.break_seconds)
        elif self.phase is Phase.BREAK_DONE:
            self.session += 1
            self._begin(Phase.SESSION, self.config.session_seconds)

    def tick(self) -> Event | None:
        """Called once a second; returns an event when a phase just ended."""
        if self.phase not in TIMED or self.remaining > 0:
            return None
        return self._complete()

    # -- internals --------------------------------------------------------

    def _begin(self, phase: Phase, seconds: int) -> None:
        self.phase = phase
        self._ends_at = self._clock() + seconds
        self._gate_since = None

    def _complete(self) -> Event:
        # Count the overrun from the deadline that passed rather than from the
        # tick that noticed it: across a closed lid those are far apart.
        self._gate_since = self._ends_at
        self._ends_at = None
        if self.phase is Phase.SESSION:
            if self.session >= self.config.sessions:
                self.phase = Phase.FINISHED
                return Event.FINISHED
            self.phase = Phase.SESSION_DONE
            return Event.SESSION_ENDED
        self.phase = Phase.BREAK_DONE
        return Event.BREAK_ENDED

    # -- rendering --------------------------------------------------------

    def _detail(self) -> str | None:
        intent = _shorten(self.config.intent)
        if self.phase is Phase.IDLE:
            return None
        if self.phase is Phase.FINISHED:
            sessions = self.config.sessions
            plural = '' if sessions == 1 else 's'
            done = f'{sessions} session{plural}'
            return f'{done} · {intent}' if intent else done
        counter = f'{self.session}/{self.config.sessions}'
        return f'{counter} · {intent}' if intent else counter

    def _actions(self) -> tuple[MenuAction, ...]:
        if self.phase in (Phase.IDLE, Phase.FINISHED):
            return (MenuAction(Action.START, 'Start new timer…'),)
        if self.phase is Phase.SESSION_DONE:
            return (MenuAction(Action.GATE, 'Start break'),)
        if self.phase is Phase.BREAK_DONE:
            following = self.session + 1
            title = f'Start session {following}/{self.config.sessions}'
            return (MenuAction(Action.GATE, title),)
        return ()  # a running timer has nothing to offer but the quit button

    def view(self) -> View:
        labels = {
            Phase.IDLE: None,  # nothing to say yet, so the icon stands alone
            Phase.SESSION_DONE: 'break?',
            Phase.BREAK_DONE: 'go?',
            Phase.FINISHED: 'done',
        }
        return View(
            phase=self.phase,
            label=labels[self.phase] if self.phase in labels
            else format_clock(self.remaining),
            detail=self._detail(),
            overrun=f'-{format_clock(self.overrun)}' if self.phase in GATES else None,
            urgent=self.phase in GATES,
            actions=self._actions(),
        )


def notification_for(event: Event, pomodoro: Pomodoro) -> tuple[str, str]:
    """User facing copy for an event; shared by every frontend."""
    config = pomodoro.config
    if event is Event.SESSION_ENDED:
        return (f'Session {pomodoro.session}/{config.sessions} is over',
                'Time for a break')
    if event is Event.BREAK_ENDED:
        following = pomodoro.session + 1
        return ('The break is over',
                f'Ready for session {following}/{config.sessions}?')
    plural = '' if config.sessions == 1 else 's'
    intent = f': {config.intent}' if config.intent else ''
    return ('Pomodoro finished', f'{config.sessions} session{plural} done{intent}')

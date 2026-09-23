import sys


def main() -> None:
    if sys.platform != 'darwin':
        raise SystemExit(
            'Only macOS is supported so far. A linux frontend goes next to '
            'ui_macos.py and drives the same core.Pomodoro.')
    from .ui_macos import main as run_macos
    run_macos()


main()

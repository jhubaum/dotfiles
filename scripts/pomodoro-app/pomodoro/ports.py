"""The seams between the state machine and a platform.

`core` knows nothing about menu bars, AppKit or notify-send. A frontend supplies
these, which keeps the eventual linux port down to a new notifier and a new
display surface.
"""

from typing import Protocol


class Notifier(Protocol):
    def send(self, title: str, message: str) -> None:
        """Show a desktop notification."""

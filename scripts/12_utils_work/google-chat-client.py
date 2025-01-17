#!/usr/bin/env python3
import os
import json
import uuid
import socket
import typing
import argparse
import urllib.request


SEVERITY = [
    'DEBUG',
    'INFO',
    'WARNING',
    'ERROR',
]


class GoogleChatWebhookClient:
    """Google Chat webhook client for posting messages to a room."""

    SEVERITY_COLOR_MAPPER = {
        'DEBUG': '#000000',
        'INFO': '#1d6ac4',
        'WARNING': '#ee8155',
        'ERROR': '#c12126',
    }

    @staticmethod
    def get_args() -> argparse.Namespace:
        parser = argparse.ArgumentParser(description='Google Chat webhook client')
        parser.add_argument('message', nargs='+', help='The message to send.')
        parser.add_argument(
            '--severity',
            type=str,
            default='INFO',
            choices=SEVERITY,
            help='The severity level of the message.',
        )
        return parser.parse_args()

    def __init__(self, bot_name: str = 'aitiologic-gc-bot'):
        self.webhook_url = os.environ['GOOGLE_CHAT_WEBHOOK_URL']
        self._bot_name = bot_name
        self._instance = socket.gethostname()

    def get_level_color(self, severity: str) -> str:
        return self.SEVERITY_COLOR_MAPPER.get(severity, '#000000')

    def format_message(self, message: str, severity: str = 'INFO') -> typing.Dict[str, typing.Any]:
        """Format the message to be sent to Google Chat as a Card v2 object."""
        formatted_header = f'<font color="{self.get_level_color(severity=severity)}">{severity}</font>'
        return {
            'cardsV2': [
                {
                    'cardId': str(uuid.uuid4()),
                    'card': {
                        'header': {
                            'title': self._bot_name,
                            'subtitle': f'running on "{self._instance}"',
                            'imageUrl': 'https://developers.google.com/chat/images/quickstart-app-avatar.png',
                            'imageType': 'CIRCLE',
                        },
                        'sections': [
                            {
                                'header': formatted_header,
                                'collapsible': False,
                                'uncollapsibleWidgetsCount': 1,
                                'widgets': [{'textParagraph': {'text': message}}],
                            }
                        ],
                    },
                }
            ]
        }

    def send_message(self, message: str, severity: str = 'INFO') -> None:
        """Send a formatted message to the Google Chat room.

        :param message: The message to send.
        :param severity: The severity level of the message.
        """
        msg = self.format_message(message, severity)
        headers = {'Content-Type': 'application/json; charset=UTF-8'}
        data = json.dumps(msg).encode('utf-8')
        req = urllib.request.Request(self.webhook_url, data=data, headers=headers, method='POST')
        with urllib.request.urlopen(req) as response:
            response_status = response.status
            response_text = response.read().decode('utf-8')
            print(f'Status: {response_status}, Response: {response_text}')


if __name__ == '__main__':
    args = GoogleChatWebhookClient.get_args()
    client = GoogleChatWebhookClient()
    client.send_message(' '.join(args.message), args.severity)

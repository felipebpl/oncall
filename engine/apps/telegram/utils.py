import re
from typing import List, Union

TELEGRAM_VERIFICATION_CODE_REGEX = "^[A-Z0-9]*_[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"


def is_verification_message(text: str) -> bool:
    return bool(re.match(TELEGRAM_VERIFICATION_CODE_REGEX, text))


class CallbackQueryFactory:
    SEPARATOR = ":"

    @classmethod
    def encode_data(cls, *args: Union[str, int]) -> str:
        return cls.SEPARATOR.join(map(str, args))

    @classmethod
    def decode_data(cls, data: str) -> List[str]:
        return data.split(cls.SEPARATOR)

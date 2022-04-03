import base64

import cv2
import numpy as np


def base64_to_cv2(img: str) -> object:
    return cv2.cvtColor(
        cv2.imdecode(
            np.frombuffer(base64.b64decode(img), dtype=np.uint8),
            flags=cv2.IMREAD_COLOR),
        cv2.COLOR_BGR2RGB
    )

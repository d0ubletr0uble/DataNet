from typing import Tuple, List, Optional, Union, Any

from mtcnn import MTCNN
import numpy as np
import cv2
from numpy import ndarray
from tensorflow.keras.models import load_model
from PIL import Image


class Detector:
    def __init__(self) -> None:
        self.detector = MTCNN()
        self.facenet = load_model('ai_models/facenet')

    def get_faces(self, image: object):
        """
        Extracts faces from image and returns it as input for facenet model
        (resize to 160x160, standardize pixels)
        """
        faces = self.detector.detect_faces(image)
        cropped_faces = []
        prepared_faces = []
        for face in faces:
            if face['confidence'] < 0.9:
                continue

            x, y, w, h = face['box']

            x1, y1 = face["keypoints"]['left_eye']
            x2, y2 = face["keypoints"]['right_eye']

            cropped = image[y:y + h, x:x + w]  # bounding box crop

            prepared_face = Image.fromarray(cropped[:])
            prepared_face = prepared_face.rotate(np.rad2deg(np.arctan2(y2 - y1, x2 - x1)))
            prepared_face = np.array(prepared_face)

            factor = 160 / max(prepared_face.shape[0], prepared_face.shape[1])
            prepared_face = cv2.resize(
                prepared_face,
                (int(prepared_face.shape[1] * factor), int(prepared_face.shape[0] * factor))
            )

            diff_0 = 160 - prepared_face.shape[0]
            diff_1 = 160 - prepared_face.shape[1]
            prepared_face = np.pad(
                prepared_face,
                ((diff_0 // 2, diff_0 - diff_0 // 2), (diff_1 // 2, diff_1 - diff_1 // 2), (0, 0)),
                'constant')

            if prepared_face.shape != (160, 160, 3):
                prepared_face = cv2.resize(prepared_face, (160, 160))

            cropped = cv2.resize(cropped, (160, 160))  # keras takes 160x160 images as input
            cropped_faces.append(cropped)
            prepared_faces.append(prepared_face)

        return cropped_faces, np.asarray(prepared_faces, 'float32') / 255

    def get_embeddings(self, faces: ndarray) -> ndarray:
        return self.facenet.predict(faces)


instance = Detector()

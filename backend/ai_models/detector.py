from mtcnn import MTCNN
import numpy as np
import cv2
from numpy import ndarray
from tensorflow.keras.models import load_model


class Detector:
    def __init__(self) -> None:
        self.detector = MTCNN()
        self.facenet = load_model('ai_models/facenet')

    def get_faces(self, image: object) -> list:
        """
        Extracts faces from image and returns it as input for facenet model
        (resize to 160x160, standardize pixels)
        """
        faces = self.detector.detect_faces(np.array(image))
        cropped_faces = []
        for face in faces:
            if face['confidence'] < 0.9:
                continue

            x, y, w, h = face['box']
            cropped = image[y:y + h, x:x + w]  # bounding box crop
            cropped = cv2.resize(cropped, (160, 160))  # keras takes 160x160 images as input
            cropped_faces.append(cropped)

        return cropped_faces

    def prepare_faces(self, faces: list) -> ndarray:
        prepared = np.asarray(faces, 'float32')
        prepared = (prepared - prepared.mean()) - prepared.std()  # standardize
        return prepared

    def get_embeddings(self, faces: ndarray) -> ndarray:
        return self.facenet.predict(faces)


instance = Detector()

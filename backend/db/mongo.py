from pymongo import MongoClient
from backend.config import *


class MongoDB:
    def __init__(self):
        self.db = MongoClient(MONGO_URL).datanet


instance = MongoDB()

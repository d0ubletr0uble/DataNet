from pymongo import MongoClient


class MongoDB:
    def __init__(self):
        self.db = MongoClient('mongodb://datanet-mongodb:27017/').datanet
        # self.db = MongoClient('mongodb://127.0.0.1:27017/').datanet


instance = MongoDB()

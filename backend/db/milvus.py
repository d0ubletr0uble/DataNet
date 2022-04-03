from pymilvus import (
    connections,
    utility,
    FieldSchema, CollectionSchema, DataType,
    Collection,
)


class Milvus:
    def __init__(self):
        # connections.connect('default', host='datanet-milvus', port='19530')
        connections.connect('default', host='127.0.0.1', port='19530')

        if not utility.has_collection('users'):
            schema = CollectionSchema([
                FieldSchema(name='_id', dtype=DataType.INT64, is_primary=True, auto_id=True),
                FieldSchema(name='embeddings', dtype=DataType.FLOAT_VECTOR, dim=128)
            ])
            # TODO index

            self.users = Collection('users', schema, consistency_level='Strong')
        else:
            self.users = Collection('users')


instance = Milvus()

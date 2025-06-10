import tensorflow as tf

class DatasetLoader:
    def __init__(self, dataset_path, batch_size=32, image_size=256, channels=3, epochs=50):
        self.dataset_path = dataset_path
        self.BATCH_SIZE = batch_size
        self.IMAGE_SIZE = image_size
        self.CHANNELS = channels
        self.EPOCHS = epochs
        self.dataset = None
        self.class_names = []
        self.train_ds = None
        self.val_ds = None
        self.test_ds = None

    def load_dataset(self):
        """Load dataset from directory"""
        self.dataset = tf.keras.preprocessing.image_dataset_from_directory(
            self.dataset_path,
            seed=123,
            shuffle=True,
            image_size=(self.IMAGE_SIZE, self.IMAGE_SIZE),
            batch_size=self.BATCH_SIZE
        )
        return self.dataset

    def get_class_names(self):
        """Get class names from loaded dataset"""
        if self.dataset is None:
            raise ValueError("Dataset not loaded - call load_dataset() first")
        self.class_names = self.dataset.class_names
        return self.class_names

    def split_dataset(self, train_split=0.8, val_split=0.1, test_split=0.1, shuffle=True, shuffle_size=10000):
        """Split dataset into train, validation, and test partitions"""
        if self.dataset is None:
            raise ValueError("Dataset not loaded - call load_dataset() first")
            
        assert (train_split + val_split + test_split) == 1
        
        ds_size = len(self.dataset)
        if shuffle:
            dataset = self.dataset.shuffle(shuffle_size, seed=12)
        else:
            dataset = self.dataset

        train_size = int(train_split * ds_size)
        val_size = int(val_split * ds_size)

        self.train_ds = dataset.take(train_size)
        self.val_ds = dataset.skip(train_size).take(val_size)
        self.test_ds = dataset.skip(train_size).skip(val_size)
        
        return self.train_ds, self.val_ds, self.test_ds

    def prepare_datasets(self, shuffle_size=1000):
        """Apply caching, shuffling and prefetching to datasets"""
        if None in (self.train_ds, self.val_ds, self.test_ds):
            raise ValueError("Datasets not split - call split_dataset() first")

        self.train_ds = self.train_ds.cache().shuffle(shuffle_size).prefetch(buffer_size=tf.data.AUTOTUNE)
        self.val_ds = self.val_ds.cache().shuffle(shuffle_size).prefetch(buffer_size=tf.data.AUTOTUNE)
        self.test_ds = self.test_ds.cache().shuffle(shuffle_size).prefetch(buffer_size=tf.data.AUTOTUNE)
        
        return self.train_ds, self.val_ds, self.test_ds
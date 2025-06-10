import tensorflow as tf

def get_data_augmentation():
    """Returns a Sequential layer for data augmentation"""
    return tf.keras.Sequential([
        tf.keras.layers.RandomFlip("horizontal_and_vertical"),
        tf.keras.layers.RandomRotation(0.2)
    ])

def apply_augmentation(dataset, augmentation_layer):
    """Applies data augmentation to a dataset"""
    return dataset.map(
        lambda x, y: (augmentation_layer(x, training=True), y)
    ).prefetch(buffer_size=tf.data.AUTOTUNE)
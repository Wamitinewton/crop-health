import tensorflow as tf

def get_resize_and_rescale(image_size):
    """Returns a Sequential layer for resizing and rescaling"""
    return tf.keras.Sequential([
        tf.keras.layers.Resizing(image_size, image_size),
        tf.keras.layers.Rescaling(1./255)
    ])
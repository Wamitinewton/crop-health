import tensorflow as tf
from tensorflow.keras import layers, models
from src.preprocessing.augment import get_data_augmentation
from src.preprocessing.normalize import get_resize_and_rescale

IMAGE_SIZE = 256 
CHANNELS = 3  
BATCH_SIZE = 32  


resize_rescale = get_resize_and_rescale(IMAGE_SIZE)
data_augmentation = get_data_augmentation()

def create_cnn_model(input_size, channels, num_classes, include_rescaling=True):
    """
    Creates a CNN model with optional preprocessing layer
    
    Args:
        input_size (int): Target size for images (width and height)
        channels (int): Number of color channels
        num_classes (int): Number of output classes
        include_rescaling (bool): Whether to include resize+rescaling layer
    
    Returns:
        tf.keras.Sequential: Configured CNN model
    """
    input_shape = (BATCH_SIZE, IMAGE_SIZE, IMAGE_SIZE, CHANNELS)

    
    model = models.Sequential()
    
    if include_rescaling:
        model.add(resize_rescale)
        model.add(data_augmentation)
    
    
    model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=input_shape))
    model.add(layers.MaxPooling2D((2, 2)))
    
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))
    
    model.add(layers.Conv2D(64, (3, 3), activation='relu'))
    model.add(layers.MaxPooling2D((2, 2)))

    model.add(layers.Flatten())
    model.add(layers.Dense(64, activation='relu'))
    model.add(layers.Dense(num_classes, activation='softmax'))

    return model

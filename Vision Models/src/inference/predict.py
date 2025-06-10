import tensorflow as tf
import numpy as np
from src.training.train import load_model_pred
from PIL import Image
import io

def prepare_image(image_bytes, image_size):
    """
    Prepare an image from raw bytes for model prediction
    
    Args:
        image_bytes (bytes): Raw image bytes
        image_size (tuple): Target size (height, width)
    
    Returns:
        np.ndarray: Preprocessed image array
    """

    img = Image.open(io.BytesIO(image_bytes))
    if img.mode != 'RGB':
        img = img.convert('RGB')
    img = img.resize(image_size)
    img_array = tf.keras.preprocessing.image.img_to_array(img)
    img_array = tf.expand_dims(img_array, 0) 
    return img_array

def predict(model, img, class_names):
    """
    Makes prediction on a single image
    
    Args:
        model (tf.keras.Model): Trained model
        img (tensor/np.ndarray): Input image tensor or array
        class_names (list): List of class names
    
    Returns:
        tuple: (predicted_class, confidence)
    """
    if not isinstance(img, tf.Tensor):
        img = tf.convert_to_tensor(img)
    img_array = tf.expand_dims(img, 0)

    predictions = model.predict(img_array)
    
    confidence = np.max(predictions[0]) * 100
    predicted_class = class_names[np.argmax(predictions[0])]
    
    return predicted_class, round(confidence, 2)


def predict_from_saved_model(class_names, model, img_array, target_size):
    """
    Version with error handling and target size usage
    
    Args:
        class_names (list): List of class names
        model (tf.keras.Model): Trained model
        img_array (np.ndarray): Preprocessed image array
        target_size (tuple): Target size (height, width)
    
    Returns:
        tuple: (predicted_class, confidence)
    """
    try:
        if img_array.shape[1:3] != target_size:
            raise ValueError(f"Input image size {img_array.shape[1:3]} does not match target size {target_size}")
        
        predictions = model.predict(img_array)
        if predictions.shape[1] != len(class_names):
            raise ValueError("Model output doesn't match class names length")
        
        confidence = round(100 * np.max(predictions[0]), 2)
        predicted_class = class_names[np.argmax(predictions[0])]
        
        return predicted_class, confidence
    
    except Exception as e:
        print(f"Prediction failed: {str(e)}")
        return None, None
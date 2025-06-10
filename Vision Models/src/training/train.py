import tensorflow as tf
from tensorflow.keras.losses import SparseCategoricalCrossentropy
from tensorflow.keras.models import load_model
import os
def train_model(model, train_ds, val_ds, batch_size, epochs, input_shape):
    """
    Compiles and trains a CNN model
    
    Args:
        model (tf.keras.Model): Model to train
        train_ds (tf.data.Dataset): Training dataset
        val_ds (tf.data.Dataset): Validation dataset
        batch_size (int): Batch size for training
        epochs (int): Number of training epochs
        input_shape (tuple): Input shape with batch size
    
    Returns:
        tuple: (trained_model, training_history)
    """
    # Build and compile the model
    model.build(input_shape=input_shape)
    model.compile(
        optimizer='adam',
        loss=SparseCategoricalCrossentropy(from_logits=False),
        metrics=['accuracy']
    )

    # Train the model
    history = model.fit(
        train_ds,
        batch_size=batch_size,
        validation_data=val_ds,
        verbose=1,
        epochs=epochs,
    )

    return model, history

def save_model(model, save_path, save_format='h5'):
    """
    Save trained model to specified path
    Args:
        model (tf.keras.Model): Trained model to save
        save_path (str): Path to save the model
        save_format (str): Format to save ('tf' or 'h5')
    """
    model.save(save_path, save_format=save_format)
    print(f"Model saved successfully at {save_path}")

def load_model_pred(model_path):
    """
    Load a saved model from specified path
    Args:
        model_path (str): Path to saved model
    Returns:
        tf.keras.Model: Loaded model

    """
    model = load_model(model_path)
    return model



def select_model(saved_models_dir, plant_name):
        """
        Selects the model to be used based on the plant name.
        
        Args:
            saved_models_dir (str): Directory containing saved models.
            plant_name (str): Name of the plant the model predicts.
        
        Returns:
            str: Path to the selected model file.
        """
        model_file = os.path.join(saved_models_dir, f"{plant_name}.h5")
        if os.path.exists(model_file):
            print(f"Model for {plant_name} found: {model_file}")
            return model_file
        else:
            raise FileNotFoundError(f"No model found for plant: {plant_name}")
    


from src.training.train import train_model
from src.models.cnn import create_cnn_model
from src.inference.predict import predict, load_and_preprocess_image
from src.preprocessing.load_dataset import DatasetLoader
from src.training.train import save_model
from src.inference.predict import predict_from_saved_model

#constants
IMAGE_SIZE = 256  # Target size for images (width and height)
CHANNELS = 3  # Number of color channels
BATCH_SIZE = 32  # Batch size for training
EPOCHS = 50  # Number of epochs for training
# Load dataset
dataset_path = "data/raw/plantvillage/PlantVillage"
dataset_loader = DatasetLoader(dataset_path, batch_size=BATCH_SIZE, image_size=IMAGE_SIZE, channels=CHANNELS, epochs=EPOCHS)
dataset = dataset_loader.load_dataset()

class_names = dataset_loader.get_class_names()

train_ds, val_ds, test_ds = dataset_loader.split_dataset(train_split=0.8, val_split=0.1, test_split=0.1)

dataset_loader.prepare_datasets(shuffle_size=1000)



# Print class names
print("Class names:", class_names)

# Print dataset sizes
print("Train dataset size:", len(train_ds))
print("Validation dataset size:", len(val_ds))
print("Test dataset size:", len(test_ds))

# # After dataset preparation
# model = create_cnn_model(
#     input_size=256,
#     channels=3,
#     num_classes=len(class_names),
#     include_rescaling=False  # If preprocessing is already done in dataset
# )

# trained_model, history = train_model(
#     model=model,
#     train_ds=train_ds,
#     val_ds=val_ds,
#     batch_size=BATCH_SIZE,
#     epochs=EPOCHS,
#     input_shape=(BATCH_SIZE, IMAGE_SIZE, IMAGE_SIZE, CHANNELS)
# )



# # Load and preprocess image
# img = load_and_preprocess_image("path/to/image.jpg", (256, 256))

# # Make prediction
# class_name, confidence = predict(trained_model, img, class_names)
# print(f"Predicted: {class_name} with {confidence}% confidence")

# Save model
# save_model(model=model, "plant_model.h5", save_format='h5')

# # Make prediction
# class_label, confidence = predict_from_saved_model(
#     model_path="plant_model.h5",
#     img_path="unknown_plant.jpg",
#     class_names=class_names
# )

# print(f"Predicted: {class_label} with {confidence}% confidence")

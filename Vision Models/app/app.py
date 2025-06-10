from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import tensorflow as tf
from src.training.train import load_model_pred  
from PIL import Image
from src.inference.predict import prepare_image,predict,predict_from_saved_model  
import io

class_names = ['Early Blight', 'Late Blight', 'Healthy'] 

app = Flask(__name__)
CORS(app) 

model = load_model_pred('src/training/saved_model/potatoes.h5') 

@app.route('/predict', methods=['POST'])
def predict_endpoint():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in the request'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    


    if file:
        try:
            image_bytes = file.read()
            img_array = prepare_image(image_bytes, (256, 256)) 

            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
        

        try:
            predicted_class, confidence = predict_from_saved_model(class_names,model, img_array, target_size=(256, 256))

            return jsonify({
                'predicted_class': predicted_class,
                'confidence': f"{int(confidence)} %",
            })

        except Exception as e:
            return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)

import json

class GeminiAgronomistChatbot:
    def __init__(self):
        self.disease_database = {
            "powdery mildew": {
                "description": "Powdery mildew is a fungal disease that affects a wide range of plants.",
                "symptoms": "White powdery spots on leaves, stems, and flowers.",
                "coping_mechanism": "Ensure proper air circulation, avoid overhead watering, and use fungicides if necessary.",
                "prevention": "Plant resistant varieties and maintain proper spacing between plants."
            },
            "blight": {
                "description": "Blight is a plant disease caused by fungi or bacteria.",
                "symptoms": "Sudden yellowing, browning, or wilting of leaves and stems.",
                "coping_mechanism": "Remove infected plants, apply appropriate fungicides or bactericides.",
                "prevention": "Rotate crops and avoid planting in infected soil."
            }
        }

    def get_disease_info(self, disease_name):
        disease_info = self.disease_database.get(disease_name.lower())
        if disease_info:
            return json.dumps(disease_info, indent=4)
        else:
            return json.dumps({"error": "Disease not found in the database."}, indent=4)

# Example usage
if __name__ == "__main__":
    chatbot = GeminiAgronomistChatbot()
    disease_name = input("Enter the name of the plant disease: ").strip()
    response = chatbot.get_disease_info(disease_name)
    print(response)

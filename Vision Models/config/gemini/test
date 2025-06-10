import requests
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")
API_URL = os.getenv("GEMINI_API_URL", "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent")

def generate_content(prompt_text):
    headers = {
        "Content-Type": "application/json"
    }
    payload = {
        "contents": [
            {
                "parts": [
                    {
                        "text": prompt_text
                    }
                ]
            }
        ]
    }
    response = requests.post(f"{API_URL}?key={API_KEY}", json=payload, headers=headers)
    if response.status_code == 200:
        data = response.json()
        result = {
            "blight": {
                "description": data.get("description", "Blight is a plant disease caused by fungi or bacteria."),
                "symptoms": data.get("symptoms", "Sudden yellowing, browning, or wilting of leaves and stems."),
                "coping_mechanism": data.get("coping_mechanism", "Remove infected plants, apply appropriate fungicides or bactericides."),
                "prevention": data.get("prevention", "Rotate crops and avoid planting in infected soil."),
                "additional_info": data.get("additional_info", "Ensure proper drainage and avoid overwatering.")
            }
        }
        return result
    else:
        return {"error": f"Error: {response.status_code}, {response.text}"}

# Example usage
prompt_text = input("Enter your prompt: ").strip()
response = generate_content(prompt_text)
print(response)

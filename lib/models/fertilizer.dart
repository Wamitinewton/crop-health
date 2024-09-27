// lib/models/fertilizer_input.dart

class FertilizerInput {
  double temperature;
  double humidity;
  double moisture;
  String soilType;
  String cropType;
  double nitrogen;
  double potassium;
  double phosphorous;

  FertilizerInput({
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.soilType,
    required this.cropType,
    required this.nitrogen,
    required this.potassium,
    required this.phosphorous,
  });

  factory FertilizerInput.fromJson(Map<String, dynamic> json) {
    return FertilizerInput(
      temperature: json['Temparature'].toDouble(),
      humidity: json['Humidity '].toDouble(),
      moisture: json['Moisture'].toDouble(),
      soilType: json['Soil Type'],
      cropType: json['Crop Type'],
      nitrogen: json['Nitrogen'].toDouble(),
      potassium: json['Potassium'].toDouble(),
      phosphorous: json['Phosphorous'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Temparature': temperature,
      'Humidity ': humidity,
      'Moisture': moisture,
      'Soil Type': soilType,
      'Crop Type': cropType,
      'Nitrogen': nitrogen,
      'Potassium': potassium,
      'Phosphorous': phosphorous,
    };
  }
}

import 'package:farmshield/models/fertilizer.dart';
import 'package:farmshield/services/fertilizer_service.dart';
import 'package:flutter/material.dart';

class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  State<FertilizerRecommendationScreen> createState() =>
      _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState
    extends State<FertilizerRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FertilizerService _apiService =
      FertilizerService(baseUrl: 'https://c368-196-96-212-174.ngrok-free.app');

  late FertilizerInput _input;
  String _recommendation = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _input = FertilizerInput(
      temperature: 26.0,
      humidity: 52.0,
      moisture: 38.0,
      soilType: "Sandy",
      cropType: "Maize",
      nitrogen: 37.0,
      potassium: 0.0,
      phosphorous: 0.0,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final recommendation =
            await _apiService.getFertlizerRecommendations(_input);
        setState(() {
          _recommendation = recommendation;
          _isLoading = false;
        });
      } on HttpException catch (e) {
        setState(() {
          _recommendation = "Error: ${e.message}";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fertilizer Recommendation')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Temperature'),
              initialValue: _input.temperature.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _input.temperature = double.parse(value!),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a value' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Humidity'),
              initialValue: _input.humidity.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _input.humidity = double.parse(value!),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a value' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Moisture'),
              initialValue: _input.moisture.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _input.moisture = double.parse(value!),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a value' : null,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Soil Type'),
              value: _input.soilType,
              items: ['Loamy', 'Clayey', 'Sandy', 'Black', 'Red']
                  .map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (value) => setState(() => _input.soilType = value!),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Crop Type'),
              value: _input.cropType,
              items: [
                'Sugarcane',
                'Cotton',
                'Millets',
                'Paddy',
                'Pulses',
                'Wheat',
                'Tobacco',
                'Barley',
                'Oil seeds',
                'Ground Nuts',
                'Maize',
              ].map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (value) => setState(() => _input.cropType = value!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nitrogen'),
              initialValue: _input.nitrogen.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _input.nitrogen = double.parse(value!),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a value' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Potassium'),
              initialValue: _input.potassium.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _input.potassium = double.parse(value!),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a value' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Phosphorous'),
              initialValue: _input.phosphorous.toString(),
              keyboardType: TextInputType.number,
              onSaved: (value) => _input.phosphorous = double.parse(value!),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a value' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Get Recommendation'),
            ),
            const SizedBox(height: 20),
            Text('Recommendation: $_recommendation',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

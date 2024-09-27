// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:farmshield/feature_message/controllers/appwrite_controllers.dart';
import 'package:farmshield/feature_message/providers/user_data_provider.dart';
import 'package:farmshield/gemini_bloc/gemini_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/provider/dark_theme_provider.dart';

// ignore: must_be_immutable
class DetectionDeteils extends StatefulWidget {
  DetectionDeteils({super.key, required this.image, required this.results});

  File image;
  List results;

  @override
  State<DetectionDeteils> createState() => _DetectionDeteilsState();
}

class _DetectionDeteilsState extends State<DetectionDeteils> {
  late GeminiBloc geminiBloc;

  @override
  void initState() {
    super.initState();
    geminiBloc = BlocProvider.of<GeminiBloc>(context);

    if (widget.results.isNotEmpty) {
      final diseaseName = widget.results[0]['label']
          .toString()
          .replaceAll(RegExp(r'\d+'), '')
          .trim();

      geminiBloc.add(GeminiSubmit(text: """
Provide a comprehensive overview of the disease known as $diseaseName. 
Include the following details:
1. Symptoms: What are the common visible symptoms observed in crops affected by this disease?
2. **Cause**: What is the primary cause or pathogen responsible for this disease (e.g., fungi, bacteria, virus, etc.)?
3. **Spread**: How does this disease typically spread among crops (e.g., through soil, water, air, pests)?
4. **Affected Crops**: Which specific types of crops are most vulnerable to this disease?
5. **Impact on Yield**: How does the disease affect the crop's health and productivity? What are the potential losses in yield if the disease is not controlled?
6. **Prevention**: What preventive measures can farmers take to reduce the risk of this disease affecting their crops (e.g., crop rotation, resistant varieties)?
7. **Treatment**: What are the best treatment options available to control or eradicate the disease (e.g., agro-chemicals, organic solutions)?
8. **Environmental Factors**: Are there any specific environmental conditions (such as temperature, humidity, soil quality) that increase the likelihood of this disease?
9. **Time of Occurrence**: During what seasons or crop growth stages is this disease most likely to appear?
10. **Recommended Practices**: Provide any general recommendations for farm management practices that can help mitigate the impact of this disease in the long run.
"""));
    }
  }


  Future<void> saveDetectionData(String description) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('detection_history') ?? [];

    final imageHash = await _computeImageHash(widget.image);
    final newEntry = {
      'image': widget.image.path,
      'imageHash': imageHash,
      'disease': widget.results.isNotEmpty ? widget.results[0]['label'].toString() : 'Unknown',
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Check if an entry with the same image hash already exists
    final existingIndex = history.indexWhere((item) {
      final decoded = json.decode(item);
      return decoded['imageHash'] == imageHash;
    });

    if (existingIndex != -1) {
      // Update existing entry
      history[existingIndex] = json.encode(newEntry);
    } else {
      // Add new entry
      history.add(json.encode(newEntry));
    }

    await prefs.setStringList('detection_history', history);
  }

  Future<String> _computeImageHash(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: widget.results.isEmpty
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Warning',
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 30,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          )
                        : Text(
                            'identifydisease'.tr,
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                      child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10)),
                          child: Image.file(
                            widget.image,
                            fit: BoxFit.fill,
                          ))),
                  const SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Text(
                      widget.results.isEmpty
                          ? 'cautionerror'.tr
                          : widget.results[0]['label']
                              .toString()
                              .replaceAll(RegExp(r'\d+'), '')
                              .trim()
                              .toString()
                              .tr,
                      style: const TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18.0, 8, 18, 8),
                    child: Center(
                        child: widget.results.isEmpty
                            ? const Text(
                                'Description : This is not a leaf object',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              )
                            : BlocBuilder<GeminiBloc, GeminiState>(
                                builder: (context, state) {
                                if (state is OnDataReceived) {
                                  String formattedResponse = state.chat.output!
                                      .replaceAll('**', '')
                                      .replaceAll('\\n', '\n');
                                  if (formattedResponse
                                      .contains('No Leaf Found')) {
                                    return const Text(
                                      'Description : This is not a leaf object',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  } else {
                                    saveDetectionData(formattedResponse);
                                    return Column(
                                      children: [
                                        Text(
                                          "possible causes".tr +
                                              " : " +
                                              formattedResponse,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        ElevatedButton(
                                          onPressed: () async {
                                            bool sessionValid =
                                                await checkUserSession(context);
                                            if (sessionValid) {
                                              Navigator.pushNamed(
                                                  context, "/home");
                                            } else {
                                              Navigator.pushNamed(
                                                  context, "/login");
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                            minimumSize: const Size(150, 40),
                                          ),
                                          child: const Text(
                                            "Chat With Expert",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                } else if (state is OnError) {
                                  return Text(
                                    "Error: ${state.message}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              })),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // ignore: non_constant_identifier_names
  List Diseases(String name, languageChange) {
    String causes = '';
    String solution = '';
    String formattedDisease = name.replaceAll(RegExp(r'\d+'), '');

    if (languageChange.getDarkTheme == "ma") {
      switch (formattedDisease.trim()) {
        case "Apple Black Rot":
          causes = "कवक  कारणीभूत.";
          solution = "संक्रमित क्षेत्रे काढा, फंगीसायड वापरा.";
          break;

        case "Apple Cedar Rust":
          causes = "कवक  कारणीभूत.";
          solution = "जूनिपर पौधांची दूरस्थी करा, फंगीसायड वापरा.";
          break;

        case "Apple Healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, नियमित मॉनिटरिंग.";
          break;

        case "Apple Scab":
          causes = "कवक Venturia inaequalis कारणीभूत.";
          solution = "फंगीसायड लागू करा, संक्रमित शाखांची कंटें काढा.";
          break;

        case "Blueberry Healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, किडकांसाठी मॉनिटरिंग.";
          break;

        case "Cherry Healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, नियमित मॉनिटरिंग.";
          break;

        case "Cherry Powdery mildew":
          causes = "कवक  कारणीभूत.";
          solution = "फंगीसायड लागू करा, संक्रमित भाग काढा.";
          break;

        case "Corn Cercospora leaf spot or Gray leaf spot":
          causes = "कवक Cercospora zeae-maydis कारणीभूत.";
          solution = "प्रतिरोधी प्रजांचा वापर करा, फंगीसायड लागू करा.";
          break;

        case "Corn Common rust":
          causes = "कवक  कारणीभूत.";
          solution = "प्रतिरोधी प्रजांचा वापर करा, फंगीसायड लागू करा.";
          break;

        case "Corn healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "फसळांची परिस्थिती बदला, चंद्रोदय उत्पादन साधारित्य.";
          break;

        case "Corn Northern Leaf Blight":
          causes = "कवक  कारणीभूत.";
          solution = "प्रतिरोधी प्रजांचा वापर करा, फंगीसायड लागू करा.";
          break;

        case "Grape Black rot":
          causes = "कवक  कारणीभूत.";
          solution = "संक्रमित क्षेत्रे काढा, फंगीसायड लागू करा.";
          break;

        case "Grape Esca (Black Measles)":
          causes = "विविध कवक, सहितकं  कारणीभूत.";
          solution = "संक्रमित डाळे काढा, फंगीसायड लागू करा.";
          break;

        case "Grape healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, नियमित मॉनिटरिंग.";
          break;

        case "Grape Leaf blight (Isariopsis Leaf Spot)":
          causes = "कवक  कारणीभूत.";
          solution = "फंगीसायड लागू करा, संक्रमित भाग काढा.";
          break;

        case "Mango Anthracnose":
          causes = "कवक कारणीभूत.";
          solution = "संक्रमित क्षेत्रे काढा, फंगीसायड लागू करा.";
          break;

        case "Mango Bacterial Canker":
          causes = "बॅक्टीरियम  कारणीभूत.";
          solution = "संक्रमित क्षेत्रे काढा, तांबटाचे स्प्रे लागू करा.";
          break;

        case "Mango Cutting Weevil":
          causes = "कीडा  कारणीभूत.";
          solution = "उपयुक्त कीटकनाशक लागू करा, संक्रमित भाग काढा.";
          break;

        case "Mango Die Back":
          causes = "विविध कारके, कवक आणि पर्यावरणीय तंतूंसह कारणीभूत.";
          solution = "संक्रमित क्षेत्रे काढा, सांस्कृतिक प्रथा सुधारा.";
          break;

        case "Mango Gall Midge":
          causes = "कीडा  कारणीभूत.";
          solution = "संक्रमित पौध भाग काढा, कीटकनाशक लागू करा.";
          break;

        case "Mango Healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, नियमित मॉनिटरिंग.";
          break;

        case "Mango Powdery Mildew":
          causes = "कवक Oidium mangiferae कारणीभूत.";
          solution = "फंगीसायड लागू करा, हवेची सरकुलेशन सुधारा.";
          break;

        case "Mango Sooty Mould":
          causes =
              "कीटकांच्या शहाण्यांनी निकाललेल्या मधूसूटीवर वाढलेल्या कवकाने कारणीभूत.";
          solution =
              "कीटकांचे नियंत्रण करा, संक्रमित क्षेत्रे सफाई आणि उपचार करा.";
          break;

        case "Orange Haunglongbing (Citrus greening)":
          causes = "बॅक्टीरियम कारणीभूत.";
          solution =
              "संक्रमित झाडे काढा, सिट्रस सायलिडचा नियंत्रण करा, एंटीबायोटिक लागू करा.";
          break;

        case "Peach Bacterial spot":
          causes = "बॅक्टीरियम  कारणीभूत.";
          solution = "संक्रमित शाखांची कंटें काढा, तांबटाचे स्प्रे लागू करा.";
          break;

        case "Peach healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, नियमित मॉनिटरिंग.";
          break;

        case "Potato Early blight":
          causes = "कवक कारणीभूत.";
          solution =
              "फसलांचा परिस्थिती बदला, फंगीसायड लागू करा, चंद्रोदय उत्पादन साधारित्य.";
          break;

        case "Potato healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "फसलांचा परिस्थिती बदला, चंद्रोदय उत्पादन साधारित्य.";
          break;

        case "Potato Late blight":
          causes = "ओमायसिट्स  कारणीभूत.";
          solution = "प्रतिरोधी प्रजांचा वापर करा, फंगीसायड लागू करा.";
          break;

        case "Raspberry healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, किडकांसाठी मॉनिटरिंग.";
          break;

        case "Soybean healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "फसलांचा परिस्थिती बदला, चंद्रोदय उत्पादन साधारित्य.";
          break;

        case "Squash Powdery mildew":
          causes = "कवक कारणीभूत.";
          solution = "फंगीसायड लागू करा, प्रतिरोधी प्रजांचा वापर करा.";
          break;

        case "Strawberry healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "चंद्रोदय उत्पादन साधारित्य, किडकांसाठी मॉनिटरिंग.";
          break;

        case "Strawberry Leaf scorch":
          causes = "बॅक्टीरियम  कारणीभूत.";
          solution = "संक्रमित पाने काढा, कॉपर-आधारित स्प्रे लागू करा.";
          break;

        case "Tomato Bacterial spot":
          causes = "बॅक्टीरियम  कारणीभूत.";
          solution = "संक्रमित क्षेत्रे काढा, कॉपर-आधारित स्प्रे लागू करा.";
          break;

        case "Tomato Early blight":
          causes = "कवक  कारणीभूत.";
          solution =
              "पुनरावृत्ती करा, फंगीसायड लागू करा, चंद्रोदय उत्पादन साधारित्य.";
          break;

        case "Tomato healthy":
          causes = "कोणतेही विशिष्ट रोग ओळखले नाहीत.";
          solution = "पुनरावृत्ती करा, चंद्रोदय उत्पादन साधारित्य.";
          break;

        case "Tomato Late blight":
          causes = "ऊमायसेट  कारणीभूत.";
          solution = "प्रतिरोधी प्रजांचा वापर करा, फंगीसायड लागू करा.";
          break;

        case "Tomato Leaf Mold":
          causes = "कवक  कारणीभूत.";
          solution = "संक्रमित पाने काढा, फंगीसायड लागू करा.";
          break;

        case "Tomato Septoria leaf spot":
          causes = "कवक  कारणीभूत.";
          solution = "संक्रमित पाने काढा, फंगीसायड लागू करा.";
          break;

        case "Tomato Spider mites Two spotted spider mite":
          causes = "अणुस्थान तेंडु ऊरल्यामुळे कारणीभूत.";
          solution = "एकॅरिसायड्स लागू करा, उच्च आर्द्रता बनावट बनवा.";
          break;

        case "Tomato Target Spot":
          causes = "कवक कारणीभूत.";
          solution = "संक्रमित क्षेत्रे काढा, फंगीसायड लागू करा.";
          break;

        case "Tomato Mosaic Virus":
          causes = "विविध मोझेक व्हायरसांकिंवा कारणीभूत.";
          solution =
              "एफिड्सचा नियंत्रण करा, व्हायरस-प्रतिरोधी प्रजांचा वापर करा.";
          break;

        case "Tomato Yellow Leaf Cur Virus":
          causes = "व्ह्याइटफ्लाय-संचालित बेगोमोवायरस कारणीभूत.";
          solution =
              "व्ह्याइटफ्लायचा नियंत्रण करा, व्हायरस-प्रतिरोधी प्रजांचा वापर करा.";
          break;

        case "Background Without Images":
          causes = "हे सठीस छायाचित्र नाही";
          solution = "आपल्याकडून हे पान कसंबर केलं नाही.";
          break;

        default:
          causes = "";
          solution = "";
          break;
      }

      return [causes, solution];
    } else {
      switch (formattedDisease.trim()) {
        case "Apple Black Rot":
          causes = "Caused by the fungus Botryosphaeria obtusa.";
          solution = "Prune infected areas, use fungicides.";
          break;

        case "Apple Cedar Rust":
          causes = "Caused by the fungus Gymnosporangium juniperi-virginianae.";
          solution = "Remove nearby juniper plants, apply fungicides.";
          break;

        case "Apple Healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good orchard hygiene, regular monitoring.";
          break;

        case "Apple Scab":
          causes = "Caused by the fungus Venturia inaequalis.";
          solution = "Apply fungicides, prune infected branches.";
          break;

        case "Blueberry Healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good field hygiene, monitor for pests.";
          break;

        case "Cherry Healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good orchard hygiene, regular monitoring.";
          break;

        case "Cherry Powdery mildew":
          causes = "Caused by Podosphaera spp.";
          solution = "Apply fungicides, prune affected parts.";
          break;

        case "Corn Cercospora leaf spot or Gray leaf spot":
          causes = "Caused by the fungus Cercospora zeae-maydis.";
          solution = "Use resistant varieties, apply fungicides.";
          break;

        case "Corn Common rust":
          causes = "Caused by the fungus Puccinia sorghi.";
          solution = "Use resistant varieties, apply fungicides.";
          break;

        case "Corn healthy":
          causes = "No specific disease identified.";
          solution = "Rotate crops, practice good field hygiene.";
          break;

        case "Corn Northern Leaf Blight":
          causes = "Caused by the fungus Exserohilum turcicum.";
          solution = "Use resistant varieties, apply fungicides.";
          break;

        case "Grape Black rot":
          causes = "Caused by the fungus Guignardia bidwellii.";
          solution = "Prune infected areas, apply fungicides.";
          break;

        case "Grape Esca (Black Measles)":
          causes = "Caused by multiple fungi including Phaeoacremonium spp.";
          solution = "Prune infected vines, apply fungicides.";
          break;

        case "Grape healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good vineyard hygiene, regular monitoring.";
          break;

        case "Grape Leaf blight (Isariopsis Leaf Spot)":
          causes = "Caused by the fungus Isariopsis spp.";
          solution = "Apply fungicides, prune affected parts.";
          break;

        case "Mango Anthracnose":
          causes = "Caused by the fungus Colletotrichum gloeosporioides.";
          solution = "Prune infected areas, apply fungicides.";
          break;

        case "Mango Bacterial Canker":
          causes = "Caused by the bacterium Xanthomonas campestris.";
          solution = "Prune infected areas, apply copper-based sprays.";
          break;

        case "Mango Cutting Weevil":
          causes = "Caused by the weevil Hypomeces squamosus.";
          solution = "Apply appropriate insecticides, prune affected parts.";
          break;

        case "Mango Die Back":
          causes =
              "Caused by various factors, including fungi and environmental stress.";
          solution = "Prune infected areas, improve cultural practices.";
          break;

        case "Mango Gall Midge":
          causes = "Caused by the midge Procontarinia mangiferae.";
          solution =
              "Prune and destroy affected plant parts, apply insecticides.";
          break;

        case "Mango Healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good orchard hygiene, regular monitoring.";
          break;

        case "Mango Powdery Mildew":
          causes = "Caused by the fungus Oidium mangiferae.";
          solution = "Apply fungicides, improve air circulation.";
          break;

        case "Mango Sooty Mould":
          causes =
              "Caused by the growth of sooty mold on honeydew excreted by insects.";
          solution = "Control insect pests, clean and treat affected areas.";
          break;

        case "Mango Diseased":
          causes =
              "Caused by the growth of sooty mold on honeydew excreted by insects.";
          solution = "Control insect pests, clean and treat affected areas.";
          break;

        case "Orange Haunglongbing (Citrus greening)":
          causes = "Caused by the bacterium Candidatus Liberibacter asiaticus.";
          solution =
              "Remove infected trees, control citrus psyllid, apply antibiotics.";
          break;

        case "Peach Bacterial spot":
          causes = "Caused by the bacterium Xanthomonas arboricola pv. pruni.";
          solution = "Prune infected branches, apply copper-based sprays.";
          break;

        case "Peach healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good orchard hygiene, regular monitoring.";
          break;

        case "Potato Early blight":
          causes = "Caused by the fungus Alternaria solani.";
          solution =
              "Rotate crops, apply fungicides, practice good field hygiene.";
          break;

        case "Potato healthy":
          causes = "No specific disease identified.";
          solution = "Rotate crops, practice good field hygiene.";
          break;

        case "Potato Late blight":
          causes = "Caused by the oomycete Phytophthora infestans.";
          solution = "Use resistant varieties, apply fungicides.";
          break;

        case "Raspberry healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good field hygiene, monitor for pests.";
          break;

        case "Soybean healthy":
          causes = "No specific disease identified.";
          solution = "Rotate crops, practice good field hygiene.";
          break;

        case "Squash Powdery mildew":
          causes = "Caused by the fungus Podosphaera spp.";
          solution = "Apply fungicides, plant resistant varieties.";
          break;

        case "Strawberry healthy":
          causes = "No specific disease identified.";
          solution = "Maintain good field hygiene, monitor for pests.";
          break;

        case "Strawberry Leaf scorch":
          causes = "Caused by the bacterium Xanthomonas fragariae.";
          solution = "Prune infected leaves, apply copper-based sprays.";
          break;

        case "Tomato Bacterial spot":
          causes =
              "Caused by the bacterium Xanthomonas campestris pv. vesicatoria.";
          solution = "Prune infected areas, apply copper-based sprays.";
          break;

        case "Tomato Early blight":
          causes = "Caused by the fungus Alternaria solani.";
          solution =
              "Rotate crops, apply fungicides, practice good field hygiene.";
          break;

        case "Tomato healthy":
          causes = "No specific disease identified.";
          solution = "Rotate crops, practice good field hygiene.";
          break;

        case "Tomato Late blight":
          causes = "Caused by the oomycete Phytophthora infestans.";
          solution = "Use resistant varieties, apply fungicides.";
          break;

        case "Tomato Leaf Mold":
          causes = "Caused by the fungus Passalora fulva.";
          solution = "Prune affected leaves, apply fungicides.";
          break;

        case "Tomato Septoria leaf spot":
          causes = "Caused by the fungus Septoria lycopersici.";
          solution = "Prune infected leaves, apply fungicides.";
          break;

        case "Tomato Spider mites Two spotted spider mite":
          causes = "Caused by Tetranychus urticae.";
          solution = "Apply acaricides, maintain proper humidity.";
          break;

        case "Tomato Target Spot":
          causes = "Caused by the fungus Corynespora cassiicola.";
          solution = "Prune infected areas, apply fungicides.";
          break;

        case "Tomato Mosaic Virus":
          causes = "Caused by various mosaic viruses.";
          solution = "Control aphids, use virus-resistant varieties.";
          break;

        case "Tomato Yellow Leaf Cur Virus":
          causes = "Caused by the whitefly-transmitted begomovirus.";
          solution = "Control whiteflies, use virus-resistant varieties.";
          break;

        case "Background Without Images":
          causes = "This is not an Proper image";
          solution = "We have not trained for this leaf";
          break;
// End of the list

        default:
          causes = "";
          solution = "";
          break;
      }

      return [causes, solution];
    }
  }

  Future<bool> checkUserSession(BuildContext context) async {
    Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    bool sessionValid = await checkSessions();

    final userName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;
    if (sessionValid && userName != null && userName.isNotEmpty) {
      return true;
    }
    return false;
  }
}


import 'package:appwrite/appwrite.dart';

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('66ed2752001a89f99303')
    .setSelfSigned(
        status: true); // For self signed certificates, only use for development

const String db = "66ed41720011e86f705d";
const String userCollection = "66ed418e000a9f15c787";
const String chatCollection = "66ed41b0000a21ee9df2";
const String storageBucket = "66ed4154003a4065ef76";
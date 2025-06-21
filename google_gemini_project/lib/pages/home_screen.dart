import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_gemini_project/bloc/gemini_bloc.dart';
import 'package:google_gemini_project/models/prompt_message_model.dart';
import 'package:google_gemini_project/pages/search_page.dart';
import 'package:lottie/lottie.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController messageQueryController = TextEditingController();
  GeminiBloc geminiBloc = GeminiBloc();

  bool _isLoading = false;

  // Picking and Sending files to backend

  Future<void> uploadMultiplePDFs() async {
    // Pick multiple files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      var uri = Uri.parse(
          'https://rag-project-1-banq.onrender.com/process-pdf'); // Use 10.0.2.2 for Android emulator

      var request = http.MultipartRequest('POST', uri);

      // Add each selected file
      for (PlatformFile file in result.files) {
        if (file.path != null) {
          print('Adding file to request: ${file.name} at ${file.path}');
          request.files.add(await http.MultipartFile.fromPath(
            'pdfs', // this key must match Flask's request.files.getlist("pdfs")
            file.path!,
            filename: file.name,
          ));
        }
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        print('✅ PDFs uploaded and processed successfully!');
      } else {
        print('❌ Failed with status code: ${response.statusCode}');
      }
    } else {
      print('⚠️ No files selected.');
    }
  }

  // Future<void> sendUserQuery(String query) async {
  //   final uri = Uri.parse(
  //       'https://truth-prototype-voice-html.trycloudflare.com/'); // Use your real URL

  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({'query': query}),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("✅ Response from backend: ${data['response']}");
  //     } else {
  //       print("❌ Error: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Exception occurred: $e");
  //   }
  // }

  @override
  void initState() {
    messageQueryController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GeminiBloc, GeminiState>(
        bloc: geminiBloc,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case PromptSuccessState:
              List<PromptMessageModel> messages =
                  (state as PromptSuccessState).promptMessages;
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // decoration: BoxDecoration(
                      //   color: Colors.black45
                      // ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      height: 150,
                      child: const Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            'Hello Zack 👋',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: messages.length > 0
                            ? ListView.builder(
                                itemCount: messages.length,
                                itemBuilder: (context, singleItem) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 10.0,
                                              spreadRadius: 4.0)
                                        ],
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black.withOpacity(0.3)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          messages[singleItem].role == "user"
                                              ? "You"
                                              : "Gemini AI",
                                          style: GoogleFonts.robotoMono(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  messages[singleItem].role ==
                                                          "user"
                                                      ? Color.fromARGB(
                                                          255, 0, 171, 206)
                                                      : Color.fromARGB(
                                                          255, 209, 0, 98)),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          messages[singleItem].parts.first.text,
                                          style: GoogleFonts.spaceGrotesk(
                                              fontSize: 15,
                                              fontStyle:
                                                  messages[singleItem].role ==
                                                          "user"
                                                      ? FontStyle.italic
                                                      : FontStyle.normal),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                            : Padding(
                                padding: const EdgeInsets.only(top: 100),
                                child: Container(
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 85),
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          'Get your answers the right way. Go Ahead!',
                                          style: TextStyle(
                                            letterSpacing: 0.2,
                                            fontSize: 20,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: _isLoading
                                                ? null
                                                : uploadMultiplePDFs,
                                            child: Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 2,
                                                    color: Color(0xFF686868)),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                              ),
                                              child: HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedFileAdd,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          // Container(
                                          //   height: 60,
                                          //   width: 60,
                                          //   decoration: BoxDecoration(
                                          //     border: Border.all(
                                          //         width: 2,
                                          //         color: Color(0xFF686868)),
                                          //     borderRadius:
                                          //         const BorderRadius.all(
                                          //             Radius.circular(10)),
                                          //   ),
                                          //   child: HugeIcon(
                                          //     icon: HugeIcons
                                          //         .strokeRoundedImageAdd01,
                                          //     color: Colors.white,
                                          //     size: 25,
                                          //   ),
                                          // )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )),
                    if (geminiBloc.generatingPrompt)
                      Row(
                        children: [
                          Container(
                              height: 100,
                              width: 100,
                              child:
                                  Lottie.asset('assets/loaders/loader.json')),
                          Text(
                            'Loading...',
                            style: GoogleFonts.robotoMono(
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.7)),
                          )
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: TextField(
                              
                              controller: messageQueryController,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4)),
                                  hintText: "Ask anything",
                                  filled: true,
                                  fillColor:
                                      Color.fromARGB(255, 36, 36, 36),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(100)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(40),
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 74, 74, 74)))),
                            ),
                          )),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              // General Prompt
                              if (messageQueryController.text.isNotEmpty) {
                                String text = messageQueryController.text;
                                messageQueryController.clear();
                                geminiBloc.add(SendMessageToPromptEvent(
                                    inputMessageQuery: text));
                              }

                              // Chat with PDf

                              // if (messageQueryController.text.isNotEmpty) {
                              //   String text = messageQueryController.text;
                              //   messageQueryController.clear();
                              //   sendUserQuery(text);
                              // }
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.white54,
                              radius: 31,
                              child: CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 23, 23, 23),
                                radius: 30,
                                child: Center(
                                  child: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // InkWell(
                          //   onTap: (() => {}),
                          //   child: CircleAvatar(
                          //     backgroundColor: Colors.black87,
                          //     radius: 30,
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}

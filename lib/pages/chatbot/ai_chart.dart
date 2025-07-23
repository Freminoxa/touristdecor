import 'package:flutter/material.dart';
import 'package:geminiapi/api/chatbot.dart';
import 'package:get/get.dart';


class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final RxString result = ''.obs;
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourist Guide AI Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.blue.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Obx(() => SingleChildScrollView(
                    child: result.value.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 100, color: Colors.blue),
                                SizedBox(height: 20),
                                Text(
                                  "Welcome! Ask me anything about your trip.",
                                  style: TextStyle(fontSize: 18, color: Colors.blue),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : Text(
                            result.value,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                  )),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: "Ask about attractions, food, or tips...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: () async {
                        if (textController.text.isNotEmpty) {
                          result.value = await GeminiAPI.getGeminiData(textController.text);
                          textController.clear();
                        }
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
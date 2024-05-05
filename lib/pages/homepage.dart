import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geminiapi/api/gemini_api.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/state_manager.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    RxString result = ''.obs;
    final textController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  keyboardType: TextInputType.text,
                  controller: textController,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (textController.text.isNotEmpty) {
                        result.value =
                            await GeminiAPI.getGeminiData(textController.text);
                      }
                      ;
                    },
                    child: Text(
                      'generate',
                      style: TextStyle(color: Colors.black),
                    )),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      textController.clear();
                    },
                    child: Text(
                      'clear',
                      style: TextStyle(color: Colors.black),
                    )),
                Obx(
                  () => Text(
                    result.value,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

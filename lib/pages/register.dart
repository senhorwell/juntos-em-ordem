import 'package:flutter/material.dart';

import '../models/checklist_item.dart';

class Register {
  showRegisterDialog(BuildContext context, selectedValue,
      TextEditingController textInput, TextEditingController pontoInput) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 243, 229, 220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                  child: Text(
                selectedValue,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffaead98),
                ),
              )),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextField(
                  onChanged: (value) {
                    textInput.text = value;
                  },
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide:
                          BorderSide(color: Color(0xffaead98), width: 5.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                          color: const Color(0xffaead98).withOpacity(0.5),
                          width: 5.0),
                    ),
                    hintText: 'Adicione a atividade',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (states) => const Color(0xffaead98),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ))),
                    onPressed: () {
                      if (textInput.text.isEmpty) {
                        return;
                      }
                      ChecklistItem(
                        id: '',
                        title: textInput.text,
                        isSelected: false,
                        ponto: int.parse(pontoInput.text),
                        pessoa: selectedValue.toLowerCase(),
                        prioridade: 0,
                      ).saveChecklistItem();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Enviar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

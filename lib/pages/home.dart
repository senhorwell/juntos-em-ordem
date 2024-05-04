import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:juntos_em_ordem/helpers/string_casting_extension.dart';
import 'package:juntos_em_ordem/pages/register.dart';

import '../database/firebase.dart';
import '../models/checklist_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future? todosFuture;
  bool isEditing = false;

  FirebaseLocalDatabase database = FirebaseLocalDatabase();

  late TextEditingController textInput = TextEditingController();
  late TextEditingController pontoInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    todosFuture = database.getTodos("jheni");
  }

  salvarTarefa() async {
    if (textInput.text == "") {
      return;
    }

    setState(() {
      isEditing = true;
    });

    await ChecklistItem(
      id: '',
      title: textInput.text,
      isSelected: false,
      ponto: int.parse(pontoInput.text),
      pessoa: database.selectedValue.toLowerCase(),
      prioridade: 0,
    ).saveChecklistItem();

    database.getTodos(database.selectedValue);

    setState(() {
      isEditing = false;
    });

    textInput.clear();
    pontoInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffefdfd7),
      body: FutureBuilder(
        future: todosFuture,
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(70.0),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: database.images.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            String arquivo =
                                database.images[index].split('/').last;
                            database.getTodos(arquivo.split('.').first);

                            setState(() {
                              database.selectedImages = List<bool>.filled(
                                  database.images.length, false);
                              database.selectedImages[index] =
                                  !database.selectedImages[index];
                              database.selectedValue =
                                  arquivo.split('.').first.toCapitalized();
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (database.selectedImages[index])
                                const CircleAvatar(
                                  radius: 100,
                                  backgroundColor: Color(0xffb5b4a3),
                                ),
                              AnimatedOpacity(
                                duration: const Duration(seconds: 1),
                                opacity:
                                    !database.selectedImages[index] ? 0.3 : 1,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipOval(
                                      child: Image.asset(
                                        database.images[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Text(
                                    "R\$ ${database.selectedPoints[index]}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount: database.items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Card(
                            color: database.items[index].isSelected
                                ? const Color(0xffb5b4a3)
                                : Colors.white,
                            child: ListTile(
                              title: Text(database.items[index].title,
                                  style: TextStyle(
                                      color: database.items[index].isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 20)),
                              onTap: () async {
                                setState(() {
                                  database.items[index].isSelected =
                                      !database.items[index].isSelected;
                                });
                                await database.update(database.items[index]);
                              },
                              trailing: !database.items[index].isSelected
                                  ? IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await database
                                            .delete(database.items[index]);

                                        setState(() {
                                          database.items.removeAt(index);
                                        });
                                      },
                                    )
                                  : AnimatedPadding(
                                      padding: const EdgeInsets.all(10),
                                      duration: const Duration(seconds: 3),
                                      child: Text(
                                          database.items[index].ponto
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
                    child: ListTile(
                      title: isEditing
                          ? SizedBox(
                              height: 30,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: textInput,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Digite o título...',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: pontoInput,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Nota',
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (value) async {
                                        await salvarTarefa();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Text('Adicionar novo'),
                      trailing: IconButton(
                        icon: isEditing
                            ? const Icon(Icons.send)
                            : const Icon(Icons.add),
                        onPressed: () async {
                          await salvarTarefa();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffaead98),
        onPressed: () {
          Register().showRegisterDialog(
              context, database.selectedValue, textInput, pontoInput);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

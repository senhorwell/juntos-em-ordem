
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference todos;
  Future? todosFuture;

  final List<String> images = [
    'assets/pessoas/jheni.png',
    'assets/pessoas/well.png',
    'assets/pessoas/alice.png',
    'assets/pessoas/helena.png',
    'assets/pessoas/julia.png',
  ];
  late List<bool> selectedImages;

  List<ChecklistItem> items = [];

  String selectedValue = 'Jheni';
  String? textInput;
  String? dateInput;
  @override
  void initState() {
    super.initState();
    selectedImages = List<bool>.filled(images.length, false);
    selectedImages[0] = true;
    todosFuture = getTodos("jheni");
  }

  getTodos(String nome) {
    todos = database.ref().child(nome);
    items = [];
    todos.once().then((snapshot) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        setState(() {
          items.add(ChecklistItem(id: key, pessoa: nome, title: value["atividade"], isSelected: value["feito"] == 1 ? true : false));
        });
      });
    });
  } 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: todosFuture,
        builder: (context, snapshot) {
          return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImages = List<bool>.filled(images.length, false);
                          selectedImages[index] = !selectedImages[index];
                        });
                        String arquivo = images[index].split('/').last;
                        getTodos(arquivo.split('.').first);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (selectedImages[index])
                            CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.blue.withOpacity(0.3),
                            ),
                          AspectRatio(
                            aspectRatio: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipOval(
                                child: Image.asset(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  ListView.builder(
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Card(
                        color: items[index].isSelected ? Colors.green : null,
                        child: ListTile(
                          title: Text(items[index].title),
                          onTap: () async {
                            setState(() {
                              items[index].isSelected = !items[index].isSelected;
                            });
                            DatabaseReference ref = FirebaseDatabase.instance.ref(items[index].pessoa).child(items[index].id);
                            await ref.update({
                              "feito": items[index].isSelected ? 1 : 0,
                            });
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
        },

        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {

              return AlertDialog(
                title: const Text('Selecione uma pessoa'),
                content: Column(
                  children: [
                    DropdownButton(
                      hint: const Text('Selecione uma opção'),
                      value: selectedValue,
                      items: [
                        'Jheni',
                        'Well',
                        'Alice',
                        'Helena',
                        'Julia'
                      ].map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue!;
                        });
                      },
                    ),
                    TextField(
                      onChanged: (value) {
                        textInput = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Adicione a atividade',
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) {
                        dateInput = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Periodico ou apenas hoje?',
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('Enviar'),
                    onPressed: () async {
                      DatabaseReference ref = FirebaseDatabase.instance.ref(selectedValue!.toLowerCase()).push();
                      await ref.set({
                        "atividade": textInput,
                        "feito": 0,
                        "periodico" : dateInput,
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ChecklistItem {
  String title;
  bool isSelected;
  String id;
  String pessoa;

  ChecklistItem({required this.id, required this.title, required this.isSelected, required this.pessoa});
}

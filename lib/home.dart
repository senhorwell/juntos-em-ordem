import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase databaase = FirebaseDatabase.instance;

  final List<String> images = [
    'assets/pessoas/jheni.png',
    'assets/pessoas/well.png',
    'assets/pessoas/alice.png',
    'assets/pessoas/helena.png',
    'assets/pessoas/julia.png',
  ];

  List<ChecklistItem> items = [
    ChecklistItem(title: 'Item 1'),
    ChecklistItem(title: 'Item 2'),
    ChecklistItem(title: 'Item 3'),
    ChecklistItem(title: 'Item 4'),
    ChecklistItem(title: 'Item 5'),
    ChecklistItem(title: 'Item 6'),
    ChecklistItem(title: 'Item 7'),
    ChecklistItem(title: 'Item 8'),
    ChecklistItem(title: 'Item 9'),
    ChecklistItem(title: 'Item 3'),
    ChecklistItem(title: 'Item 3'),
    ChecklistItem(title: 'Item 3'),
    ChecklistItem(title: 'Item 3'),
    ChecklistItem(title: 'Item 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Juntos em Ordem'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
          height: MediaQuery.of(context).size.height * 0.2, // 20% da altura da tela
          child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Ação ao clicar na imagem
                print('Imagem $index clicada!');
              },
              child: AspectRatio(
                aspectRatio: 1, // Para manter a imagem quadrada
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
            );
          },
        ),
      ),
          SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: items[index].isSelected ? Colors.green : null,
                    child: ListTile(
                      title: Text(items[index].title),
                      onTap: () {
                        setState(() {
                          items[index].isSelected = !items[index].isSelected;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String? selectedValue = 'Jheni';
              String? textInput;
              String? dateInput;
              return AlertDialog(
                title: const Text('Selecione uma pessoa'),
                content: Column(
                  children: [
                    DropdownButton<String>(
                      hint: const Text('Selecione uma opção'),
                      value: selectedValue,
                      items: <String>[
                        'Jheni',
                        'Well',
                        'Alice',
                        'Helena',
                        'Julia'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue;
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
                    onPressed: () {
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
  bool isSelected = false;

  ChecklistItem({required this.title});
}

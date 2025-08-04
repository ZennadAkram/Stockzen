import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stockzen/emp.dart';
import 'package:stockzen/prod.dart';
import 'package:stockzen/sqllite.dart';
class employe extends StatefulWidget {
  const employe({super.key});

  @override
  State<employe> createState() => _employeState();
}

class _employeState extends State<employe> {
  late Future<List<emp>> prod;


  @override
  void initState() {
    super.initState();
    fetchAndInitialize();

  }

  late List<emp> fetchedData;
  late int i=0;
  Future<void> fetchAndInitialize() async {
    prod = fetch();
    fetchedData = await prod;
    addContainers(fetchedData);


  }
  Future<List<emp>> fetch() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getItemsemp();
  }

  void addContainers(List<emp> fetchedData) {
    i=fetchedData.length;
    setState(() {
      for(emp proc in fetchedData) {

        containers.add(
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                color: Color.fromRGBO(255, 255, 255, 1)),
            child: Padding(padding: EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(proc.id.toString(), style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                  ),
                 Container(
                 width: 60,
                 height: 60,
                   clipBehavior: Clip.antiAlias,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle
                   ),
                   child: Image.memory(proc.imageBytes)
                   ,
                 ),
                 SizedBox(width: 10,),

                  Expanded(
                   child: Text(proc.name, style: TextStyle(
                       fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                 ),

                  Expanded(
                    child: Text(proc.checkin, style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 25),textAlign: TextAlign.center,),
                  ),
                  Expanded(
                    child: Text(proc.checkout, style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                  ),
                  Expanded(
                    child: Text(proc.assi, style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                  ),
                  Expanded(
                    child: Text(proc.salery.toString(), style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'Delete') {
                        setState(() {
                          deleteContainerWithId(proc.id); // Delete based on id
                          final db = DatabaseHelper();
                          db.deleteemp(proc.id);
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ),


        );
      }
    });

  }
  void deleteContainerWithId(int id) {
    // Perform database deletion first
    final db = DatabaseHelper();
    db.deletepro(id).then((value) {
      // Database deletion successful, now update the UI
      setState(() {
        containers.removeWhere((container) {
          if (container is Container) {
            // Check if the child is a Padding widget
            final child = container.child;
            if (child is Padding && child.child is Row) {
              final row = child.child as Row;
              final exp=row.children[0] as Expanded;
              final containerIdText = (exp.child as Text).data;
              if (containerIdText != null) {
                try {
                  final containerId = int.parse(containerIdText);
                  if (containerId == id) {
                    fetchedData.clear();

                    return true;  // Mark this container for removal
                  }
                } catch (e) {
                  print('Error parsing container ID: $e');
                }
              }
            }
          }
          return false;
        });
      });
    }).catchError((error) {
      print("Error deleting product: $error");
      // Handle error, maybe show a message to the user
    });
  }




  List<Widget> containers = [];
  List<Widget> filterContainers(String query) {
    return containers.where((container) {
      if (container is Container) {
        final child = container.child;
        if (child is Padding && child.child is Row) {
          final row = child.child as Row;
          final exp=row.children[3] as Expanded;
          final nameText = (exp.child as Text).data; // Adjust index based on your Row structure
          return nameText != null && nameText.toLowerCase().contains(query.toLowerCase());
        }
      }
      return false;
    }).toList();
  }
  Color selectedColor = Colors.white;
  TextEditingController t=TextEditingController();
  TextEditingController t1= TextEditingController();
  TextEditingController t2= TextEditingController();
  TextEditingController t3= TextEditingController();
  TextEditingController t4= TextEditingController();
  TextEditingController control=TextEditingController();
  void addContainer(String st) {
    try {
      // Ensure inputs are not empty and are valid numbers
      if (t.text.isEmpty || t2.text.isEmpty || t3.text.isEmpty || t4.text.isEmpty) {
        throw FormatException('All fields must be filled');
      }

      int id = int.parse(t.text);

      double salery = double.parse(t4.text);

      // Add the new container
      setState(() {
        int currentIndex = containers.length;
        containers.add(
          Container(
            key: ValueKey(id), // Use id as the key
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(id.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
                  Container(

                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle

                    ),
                    child:  _selectedImage != null
                        ? Image.file(
                      _selectedImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.account_circle,size: 60,),


                  ),
                  Expanded(child: Text(t1.text, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),


                  Expanded(child: Text(t2.text, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
                  Expanded(child: Text(t3.text, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
                  Expanded(child: Text(st, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),textAlign: TextAlign.center,)),
                  Expanded(child: Text(salery.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'Delete') {

                        deleteContainerWithId(id);
                        final db = DatabaseHelper();
                        db.deleteemp(id);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });

      // Database insertion
      Uint8List bytes1 = Uint8List(0);

      if(_selectedImage!=null){
        bytes1=_selectedImage!.readAsBytesSync();
      }
      final db = DatabaseHelper();
      db.insertemply(id, t1.text,t2.text ,t3.text , st, salery,bytes1);

      // Clear text fields
      t.clear(); // Clear all input fields
      t1.clear();
      t2.clear();
      t3.clear();
      t4.clear();
    } catch (e) {
      print('Error: $e');
      // Handle error (e.g., show a dialog to the user)
    }
  }

  Future<void> showdialogue(BuildContext context) async {
    // Define the list of categories
    final List<String> categories = ['Cleaning', 'Feeding', 'Other'];

    // Create a variable to store the selected category
    String? selectedCategory;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Product info",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Existing TextFormFields
                Padding(
                  padding: EdgeInsets.all(6),
                  child: TextFormField(
                    controller: t,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "id",
                      hintStyle: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: TextFormField(
                    controller: t1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "Name",
                      hintStyle: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: TextFormField(
                    controller: t2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "Check in",
                      hintStyle: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: TextFormField(
                    controller: t3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "Check out",
                      hintStyle: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: TextFormField(
                    controller: t4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "Salary",
                      hintStyle: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(6),
                child: ElevatedButton(
                  onPressed: (){
                    _selectedImage=null;
                 _pickImage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(224, 227, 231, 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
                  ),
                  child: Text('+ picture',style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w500),),
                ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: Text('Select Category'),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      selectedCategory = newValue;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                t.clear();
                t1.clear();
                t2.clear();
                t3.clear();
                t4.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (t1.text.isNotEmpty && t4.text.isNotEmpty && selectedCategory != null) {
                  addContainer(selectedCategory!);
                }
                t.clear();
                t1.clear();
                t2.clear();
                t3.clear();
                t4.clear();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  File? _selectedImage;

  // Function to pick an image from the desktop
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Limit to image files
      allowedExtensions: ['jpg', 'jpeg', 'png'], // Supported formats
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        setState(() {
          _selectedImage = File(filePath); // Store the selected image
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Color.fromRGBO(224, 227, 231, 1),
      body: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
      Container(
      color: Color.fromRGBO(52, 64, 74, 1),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(52, 64, 74, 1),
                    width: 1,        // Border width
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    IconButton(onPressed: (){}, icon:Icon(Icons.account_circle_sharp,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
                    Text("Account",style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(255, 255, 255, 1)),)
                  ],
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(52, 64, 74, 1),
                    width: 1,        // Border width
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    IconButton(onPressed: (){Navigator.of(context).pushNamed('sales');}, icon:Icon(Icons.check_circle_outline_rounded,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
                    Text("Sell",style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(255, 255, 255, 1)),)
                  ],
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(52, 64, 74, 1),
                    width: 1,        // Border width
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    IconButton(onPressed: (){Navigator.of(context).pushNamed('product');}, icon:Icon(Icons.space_dashboard_rounded,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
                    Text("Products",style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(255, 255, 255, 1)),)
                  ],
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(52, 64, 74, 1),
                    width: 1,        // Border width
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    IconButton(onPressed: (){}, icon:Icon(Icons.shopping_cart_outlined,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
                    Text("Purshased",style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(255, 255, 255, 1)),)
                  ],
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(52, 64, 74, 1),
                    width: 1,        // Border width
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    IconButton(onPressed: (){}, icon:Icon(Icons.attach_money_outlined,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
                    Text("Transactions",style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(255, 255, 255, 1)),)
                  ],
                )),
            Container(

                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(52, 64, 74, 1),
                    width: 1,        // Border width
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    IconButton(onPressed: (){
                      Navigator.of(context).pushNamed('employee');
                    }, icon:Icon(Icons.people_alt_outlined,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
                    Text("Employees",style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(255, 255, 255, 1)),)
                  ],
                )),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color.fromRGBO(52, 64, 74, 1),
                    width: 1,        // Border width
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    IconButton(onPressed: (){}, icon:Icon(Icons.settings,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
                    Text("Settings",style: TextStyle(fontWeight: FontWeight.w600,color: Color.fromRGBO(255, 255, 255, 1)),)
                  ],
                ))
          ],
        ),
      ),
    ),
    Expanded(
    child: Padding(padding: EdgeInsets.all(14),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    children: [
    Padding(padding: EdgeInsets.all(8),
    child: Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Text('Employees',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35),)
    ],
    ),
    ),
    Padding(padding: EdgeInsets.all(14),
    child: Container(
    decoration: BoxDecoration(
    color: Color.fromRGBO(255, 255, 255, 1),
    borderRadius: BorderRadius.circular(8),
    boxShadow:[
    BoxShadow(
    blurRadius: 4.0,
    color: Color(0x33000000),
    offset: Offset(0.0, 2.0),
    ),
    ],

    ),
    child: Padding(padding: EdgeInsets.all(8),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Expanded(
    child:Padding(
    padding: EdgeInsets.all(4),
    child: TextFormField(
      controller: control,
    decoration: InputDecoration(
    suffixIcon: Icon(
    Icons.search_sharp,
    size: 30.0,
    ),
    border: OutlineInputBorder(
    borderSide: BorderSide(
    color: Color.fromRGBO(224, 227, 231, 1),
    width: 2

    ),
    borderRadius: BorderRadius.circular(8),

    ),
    focusedBorder:OutlineInputBorder(
    borderSide: BorderSide(
    color: Color.fromRGBO(224, 227, 231, 1),
    width: 2

    ),
    borderRadius: BorderRadius.circular(8)
    ) ,
    hintText: 'Search employees',
    helperStyle: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Color.fromRGBO(87, 99, 108, 1))



    ),
      onChanged: (value) {
        setState(() {
          if(control.text.isNotEmpty) {
            containers = filterContainers(value);
          }else{
            containers.clear();
            fetchedData.clear();
            fetchAndInitialize();
            addContainers(fetchedData);
          }
        });
      },

    ),
    ),

    ),
    SizedBox(width: 50,),
    ElevatedButton(onPressed: (){
      Navigator.of(context).pushNamed('records');
    },style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(255, 255, 255, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),

    child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Icon(CupertinoIcons.pen,size: 25,color: Colors.black,),
    Text('Records',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.black),)
    ],
    )),
    SizedBox(width: 50,),
      ElevatedButton(onPressed: (){
      Navigator.of(context).pushNamed('attend');
      },style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(249, 207, 88, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.timer,size: 25,color: Colors.black,),
              SizedBox(width: 5,),
              Text('Attendance',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.black),)
            ],
          )),
    SizedBox(width: 50,),
    ElevatedButton(onPressed: (){
      showdialogue(context);
    }
    ,style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(56, 150, 137, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),

    child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Icon(CupertinoIcons.add,size: 25,color: Colors.black,),
    Text(' Employees',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.black),)
    ],
    ))

    ],
    )
    ),
    ),
    ),
      Padding(
        padding: EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(0.0, 2.0),
              ),
            ],
          ),
          height: 70,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text("ID", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Employee", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Check in", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Check out", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Assignments", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Salery", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
              ],
            ),
          ),
        )

      ),
      Expanded(child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child:ListView.builder(
                    itemCount: containers.length,
                    itemBuilder: (context ,index){
                      return Column(
                        children: [
                          containers[index],
                          SizedBox(height: 5,),

                        ],
                      );
                    }
                )
            )
          ],
        ),
      ))
    ]
    )
    )
    )

    ]

      )
    );
  }
}

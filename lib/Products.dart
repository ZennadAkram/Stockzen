

import 'dart:io';
import 'dart:typed_data';

import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:stockzen/prod.dart';
import 'package:stockzen/sqllite.dart';
class product extends StatefulWidget {
  const product({super.key});

  @override
  State<product> createState() => _productsState();
}

class _productsState extends State<product> {
  late Future<List<pro>> prod;


  @override
  void initState() {
    super.initState();
  fetchAndInitialize();

  }
  late List<pro> fetchedData;
 late int i=0;
  Future<void> fetchAndInitialize() async {
    prod = fetch();
     fetchedData = await prod;
    addContainers(fetchedData);
    setState(() {
      i=count(fetchedData);
    });

  }


  Future<List<pro>> fetch() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getItems();
  }
  List<Widget> containers = [];
  void addContainer(String st) {
    try {
      // Ensure inputs are not empty and are valid numbers
      if (t.text.isEmpty || t2.text.isEmpty || t3.text.isEmpty || t4.text.isEmpty) {
        throw FormatException('All fields must be filled');
      }

      int id = int.parse(t.text);
      int quantity = int.parse(t2.text);
      double sell = double.parse(t3.text);
      double sellPrice = double.parse(t4.text);

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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(id.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center),),

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
                  SizedBox(width: 10),

                  Expanded(child: Text(t1.text, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center,)),

                  Expanded(child: Text(st, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),textAlign: TextAlign.center)),
                 Expanded(child: Text(quantity.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center),),
                  Expanded(child: Text(sell.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center)),
                  Expanded(child: Text(sellPrice.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),textAlign: TextAlign.center)),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'Delete') {
                        // Directly call deleteContainerWithId without setState
                        deleteContainerWithId(id);
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
      Uint8List bytes1 = Uint8List(0);

      if(_selectedImage!=null){
        bytes1=_selectedImage!.readAsBytesSync();
      }
      // Database insertion
      final db = DatabaseHelper();
      db.insertproducts(id, t1.text, st, quantity, sell, sellPrice,bytes1);

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


  int count(List<pro> fetchedData) {
    return fetchedData.length;
  }


  void addContainers(List<pro> fetchedData) {
    i = fetchedData.length;
    setState(() {
      containers.clear(); // Ensure to clear old containers if needed
      for (pro proc in fetchedData) {
        containers.add(
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(proc.id.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Container(
                    width: 60,
                    height: 60,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.memory(proc.image),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text(proc.name, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(child: Text(proc.category, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(child: Text(proc.quantity.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(child: Text(proc.sell.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(child: Text(proc.sellprice.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'Delete') {
                        setState(() {
                          deleteContainerWithId(proc.id); // Delete based on id
                          final db = DatabaseHelper();
                          db.deletepro(proc.id);
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

  List<Widget> filtercategory(String query) {
    return containers.where((container) {
      if (container is Container) {
        final child = container.child;
        if (child is Padding && child.child is Row) {
          final row = child.child as Row;
          final exp=row.children[4] as Expanded;
          final nameText = (exp.child as Text).data; // Adjust index based on your Row structure
          return nameText != null && nameText.toLowerCase().contains(query.toLowerCase());
        }
      }
      return false;
    }).toList();
  }

  TextEditingController t1= TextEditingController();
  TextEditingController t2= TextEditingController();
  TextEditingController t3= TextEditingController();
  TextEditingController t4= TextEditingController();
  TextEditingController t=TextEditingController();
  TextEditingController control=TextEditingController();
  final List<String> categories = ['Cleaning', 'Feeding', 'Other'];
  Future<void> showdialogue(BuildContext context) async {
    // Define the list of categories


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
                      hintText: "Bar code",
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
                      hintText: "Quantity",
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
                      hintText: "Price",
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
                      hintText: "Sell price",
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
                  child: Text("+ image",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20),),
                ),),
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

  String? selectedCategory;
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
                    IconButton(onPressed: (){}, icon:Icon(Icons.space_dashboard_rounded,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
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
    Text('Items',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35),),

      Text('${containers.length} items',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 20),)
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
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    hintText: 'Name',
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
    // SizedBox(width: 55,),
     Flexible(
       child: IconButton(onPressed:(){
         //scanBarcode();
       
       }, icon: Icon(Icons.qr_code_scanner,size: 35,)),
     ),
      //SizedBox(width: 55,),
           SizedBox(
        width: 200,
        // specify a width if needed
        child: DropdownButtonFormField<String>(
          value: selectedCategory,
          hint:  Row(
            mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Icon(Icons.folder_outlined,size: 20,color: Colors.black,),
    SizedBox(width: 5,),
    Text('Category',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black,),textAlign: TextAlign.center,),


    ],
    ), // Match the hint text style
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category, style: TextStyle(color: Colors.black, fontSize: 18)), // Match the item text style
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {

              List<pro> p1=[];

              selectedCategory = newValue;
               if(selectedCategory!='Other') {
                 for(pro p in fetchedData){
                   if(p.category==selectedCategory){
                     p1.add(p);
                   }
                 }
                 containers.clear();
                 addContainers(p1);

               }else{
                 containers.clear();
                 fetchAndInitialize();
               }
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Color.fromRGBO(249, 207, 88, 1), // Match the button background color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none, // Removes the border
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjust padding if needed
          ),
          style: TextStyle(color: Colors.black, fontSize: 18,),
          // Match the text style
        ),
      ),



      // SizedBox(width: 55,),
      ElevatedButton(onPressed: (){
        showdialogue(context);
      },style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(56, 150, 137, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.add,size: 25,color: Colors.white,),
              Text(' Product',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.white),),

            ],
          )
      ),

    ]

    ),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text("Bar Code", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Products", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Category", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Stock", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Price", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
                Expanded(child: Text("Sell Price", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25), textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),

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
    ),
    ),
    ),
    ]
      )
    );
  }
}

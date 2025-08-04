import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:stockzen/prod.dart';
import 'package:stockzen/sqllite.dart';
class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  late Future<List<pro>> prod;
  @override
  void initState() {
    super.initState();

    setState(() {

    });
    RawKeyboard.instance.addListener(_handleKeyEvent);
    RawKeyboard.instance.addListener(_handleKeyEvents);
    fetchAndInitialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

  }
  List<Map<String, dynamic>> allRows = [];


  TextEditingController conrol =TextEditingController();

  void _handleKeyEvents(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        onBarcodeScanned(barcode);
        barcode = ''; // Reset after scanning
      } else {
        barcode += event.character ?? '';
      }

    }
  }
  int ind=0;
  late List<pro> fetchedData;

  void fetchAndInitialize() async {
    prod = fetch();
    fetchedData = await prod;
     // Debug print
    addrow(fetchedData);
    setState(() {

    });
  }


  Future<List<pro>> fetch() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getItems();
  }
  List<cash> cashe=[];
  List<Widget> containers = [];
  List<Widget> rows=[];
  Color _generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255, // Alpha channel (opacity)
      random.nextInt(256), // Red channel
      random.nextInt(256), // Green channel
      random.nextInt(256), // Blue channel
    );
  }
// Map to track existing containers

  List<pro> filteredData = [];
  Map<int, Widget> productContainers = {};

  Map<int, TextEditingController> productControllers = {};
  Map<int, int> productQuantities = {};
  List<pro> filterProducts(String query) {
    List<pro> matchingProducts = [];

   for(pro p in fetchedData){
     if(p.name.toLowerCase().contains(query.toLowerCase())){
       matchingProducts.add(p);
     }
   }
    return matchingProducts;
  }

  void _searchData(String query) {
    // Get the filtered products
    List<pro> filteredProducts = filterProducts(query);

    setState(() {
      // Clear the UI rows to rebuild


      // Check if there are filtered products, then re-add them
      if (filteredProducts.isNotEmpty) {
        rows.clear();

        // Directly add filtered products to the rows
          addrow(filteredProducts);


        print(filteredProducts[0].name);
      } else {
        rows.clear();
        print("No matching products found.");
      }
    });
  }

  void addrow(List<pro> fetchedData) {
    if (fetchedData.isEmpty) return; // Exit if there's no data

    int itemsInRow = fetchedData.length > 4 ? 4 : fetchedData.length;

    setState(() {
      // Build rows directly and add them to the 'rows' list
      rows.add(
        LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = constraints.maxWidth / 4 - 16;
            double containerHeight = containerWidth * (120 / 160);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int j = 0; j < itemsInRow; j++)
                  GestureDetector(
                    key: ValueKey(fetchedData[j].id),
                    onTap: () {
                      if (productQuantities.containsKey(fetchedData[j].id)) {
                        productQuantities[fetchedData[j].id] =
                            productQuantities[fetchedData[j].id]! + 1;
                      } else {
                        productQuantities[fetchedData[j].id] = 1;
                      }
                      addcontainer(fetchedData[j], 0);
                      ind = containers.length - 1;
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                          height: containerHeight,
                          width: containerWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                            child: Image.memory(
                              fetchedData[j].image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(
                          width: containerWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: Color.fromRGBO(52, 64, 74, 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fetchedData[j].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '\$' + fetchedData[j].sellprice.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      );

      // If there are more items, call addrow recursively for the remaining items
      if (fetchedData.length > itemsInRow) {
        addrow(fetchedData.sublist(itemsInRow));
      }
    });
  }


  Widget _buildContainer(pro item, TextEditingController cont,int i) {
    // Ensure the TextEditingController is correctly initialized
    if (!productControllers.containsKey(item.id)) {
      productControllers[item.id] = TextEditingController(
        text: productQuantities[item.id]?.toString() ?? '1',
      );
    }
    cont = productControllers[item.id]!;
    if (!priceFocusNodes1.containsKey(item.id)) {
      priceFocusNodes1[item.id] = FocusNode();
    }
    FocusNode priceFocusNode = priceFocusNodes1[item.id]!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (priceFocusNode.canRequestFocus) {
        priceFocusNode.requestFocus();
      }
    });

    return Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${item.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              "${item.category}", // Optional: Replace this with actual data
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        // Display the dynamically updated price based on quantity
        Text(
          "${item.sellprice}", // Display total price
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Container(
          width: 50,
          height: 50,
          child: TextField(
            focusNode: priceFocusNode,
            textAlign: TextAlign.center,
            controller: cont,
            keyboardType: TextInputType.number,

            onChanged: (value) {
              print(value);
              setState(() {


                productQuantities[item.id] = int.tryParse(value) ?? 1;
                    updateAndReinsertContainer(item);
                if(i==0) {
                  updc(item.id, item.sellprice * int.parse(cont.text));
                }else{
                  updc(item.id, item.sellprice * productQuantities[item.id]!);
                }


                // Rebuild the widget to reflect these changes
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Color.fromRGBO(224, 227, 231, 1),
                ),
              ),
              focusColor: Color.fromRGBO(224, 227, 231, 1),
            ),
          ),
        ),
        // Display the updated total price
        SizedBox(
          width: 70,
          child: Text(
            "${item.sellprice * (productQuantities[item.id] ?? int.tryParse(cont.text) ?? 0)}",
            // Display updated total price

            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),

        IconButton(
          onPressed: () {

            deleteContainer( item);
            cashe.removeAt(delete(item.id));
            // Add delete functionality if necessary
          },
          icon: Icon(Icons.delete, color: Colors.red, size: 35),
        ),
      ],
    );
  }
  final Map<int, FocusNode> priceFocusNodes = {};
  final Map<int, FocusNode> priceFocusNodes1 = {};

  // Function to build the widget for each container
  Widget _buildContainers(pro item, TextEditingController cont, int i) {
    // Ensure the TextEditingController for quantity is initialized
    if (!productControllers.containsKey(item.id)) {
      productControllers[item.id] = TextEditingController(
        text: productQuantities[item.id]?.toString() ?? '1',
      );
    }
    cont = productControllers[item.id]!;

    // Ensure the TextEditingController for price is initialized
    if (!priceControllers.containsKey(item.id)) {
      priceControllers[item.id] = TextEditingController();
    }
    TextEditingController e3 = priceControllers[item.id]!;

    // Ensure the FocusNode for the price TextField is initialized
    if (!priceFocusNodes.containsKey(item.id)) {
      priceFocusNodes[item.id] = FocusNode();
    }
    FocusNode priceFocusNode = priceFocusNodes[item.id]!;

    // Helper method to calculate total
    double calculateTotal() {
      int quantity = productQuantities[item.id] ?? int.tryParse(cont.text) ?? 0;
      double price = double.tryParse(e3.text) ?? item.sellprice;
      double total = price * quantity;

      // Call to update and reinsert the container with the new total
      updateAndReinsertContainers(item, total);
      updc(item.id, total);

      return total;
    }

    // Request focus on the price TextField when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (priceFocusNode.canRequestFocus) {
        priceFocusNode.requestFocus();
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${item.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              "${item.category}",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        // Price TextField
        Container(
          width: 50,
          height: 50,
          child: TextField(
            focusNode: priceFocusNode, // Set the focus node
            controller: e3,
            decoration: InputDecoration(
              hintText: "0.00",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                item.sellprice = double.tryParse(value) ?? 0.00;
                calculateTotal(); // Recalculate total and update
              });
            },
          ),
        ),
        // Quantity TextField
        Container(
          width: 50,
          height: 50,
          child: TextField(
            textAlign: TextAlign.center,
            controller: cont,
            keyboardType: TextInputType.number,
            onTap: () {
              // Unfocus the price field when interacting with the quantity field
              priceFocusNode.unfocus();
            },
            onChanged: (value) {
              setState(() {
                productQuantities[item.id] = int.tryParse(value) ?? 1;
                updc(item.id, calculateTotal());

                // Recalculate total and update
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Color.fromRGBO(224, 227, 231, 1),
                ),
              ),
            ),
          ),
        ),
        // Display updated total price
        SizedBox(
          width: 70,
          child: Text(
            "${calculateTotal().toStringAsFixed(2)}", // Show the updated total
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: () {
            deleteContainer(item);
            cashe.removeAt(delete(item.id));
          },
          icon: Icon(Icons.delete, color: Colors.red, size: 35),
        ),
      ],
    );
  }

// Function to update and reinsert containers
  void updateAndReinsertContainers(pro item, double newTotal) {
    setState(() {
      // Find the index of the container in the list
      int index = containers.indexWhere((widget) {
        if (widget is Row) {
          final rowChildren = (widget as Row).children;
          return rowChildren.any((child) {
            if (child is Column) {
              final texts = (child as Column).children;
              return texts.any((textWidget) {
                return textWidget is Text && textWidget.data == item.name;
              });
            }
            return false;
          });
        }
        return false;
      });

      if (index != -1) {
        // Remove the existing widget
        containers.removeAt(index);

        // Create a new Row widget with updated total and reinsert it
        containers.insert(index, _buildContainers(item, productControllers[item.id]!, index));
      }
    });
  }
  void updateA(Widget widget,ind) {
    setState(() {

      // Ensure the widget is a Row
      if (widget is Row) {
        // Access the children of the Row
        final rowChildren = widget.children;

        // Check if the first child is a Column
        if (rowChildren.isNotEmpty && rowChildren[0] is Column) {
          final columnChildren = (rowChildren[0] as Column).children;

          // Loop through Column children to find the Text widget with the item name
          if(columnChildren.isNotEmpty && columnChildren[0] is Text){
            final tq=columnChildren[0] as Text;
            for(pro p in fetchedData){
              if(tq.data==p.name){
               p.name=p.name+'h';
               updateAndReinsertContainer(p);
            }
          }
        }
      }

    }});
  }

  Map<int, TextEditingController> priceControllers = {};
  int delete(int id){
    int s=-1;
    for(int i=0;i<cashe.length;i++){
      if(cashe[i].id==id){
        s=i;
      }
    }
    return s;
  }
  void deleteContainer(pro item) {
    setState(() {
      // Find the index of the container in the list
      int index = containers.indexWhere((widget) {
        // This assumes you have some way to identify the widget
        // For example, you can use a unique key or identifier
        if (widget is Row) {
          // Check if the Row contains the specific item
          // Adjust this logic based on your actual implementation
          final rowChildren = (widget as Row).children;
          return rowChildren.any((child) {
            if (child is Column) {
              final texts = (child as Column).children;
              return texts.any((textWidget) {
                return textWidget is Text && textWidget.data == item.name;
              });
            }
            return false;
          });
        }
        return false;
      });

      if (index != -1) {
        // Remove the container
        containers.removeAt(index);
        productControllers.remove(item.id); // Optionally remove the controller if needed
        productQuantities.remove(item.id); // Optionally remove the quantity if needed
        productContainers.remove(item.id); // Optionally remove the container if needed
      } else {
        // Optionally handle the case where the container was not found
        print("Container not found for item ${item.id}");
      }
    });
  }

  void addcontainer(pro item,int i) {
    // Ensure product quantity is initialized or retrieve existing one
    if (!productQuantities.containsKey(item.id)) {
      productQuantities[item.id] = 1; // Default to 1 if not yet present
    }

    int currentQuantity = productQuantities[item.id]!;
    TextEditingController cont;

    // Use existing controller or create a new one
    if (productControllers.containsKey(item.id)) {
      cont = productControllers[item.id]!;
      setState(() {
        cont.text = currentQuantity.toString();
        print(cont.text);

        updateAndReinsertContainer(item);
        if(i==0) {
          updc(item.id, item.sellprice * int.parse(cont.text));
        }else{
          updc(item.id, item.sellprice * productQuantities[item.id]!);
        }
      });
    } else {
      cont = TextEditingController(text: currentQuantity.toString());
      productControllers[item.id] = cont;
      setState(() {
        containers.add(_buildContainer(item, cont,i));
        cash c=cash(item.id, item.sellprice);
       cashe.add(c);


      });
    }
  }
  void addcontainers(pro item,int i) {
    // Ensure product quantity is initialized or retrieve existing one
    if (!productQuantities.containsKey(item.id)) {
      productQuantities[item.id] = 1; // Default to 1 if not yet present
    }

    int currentQuantity = productQuantities[item.id]!;
    TextEditingController cont;

    // Use existing controller or create a new one
    if (productControllers.containsKey(item.id)) {
      cont = productControllers[item.id]!;
      setState(() {
        cont.text = currentQuantity.toString();
        print(cont.text);

        updateAndReinsertContainer(item);
        if(i==0) {
          updc(item.id, item.sellprice * int.parse(cont.text));
        }else{
          updc(item.id, item.sellprice * productQuantities[item.id]!);
        }
      });
    } else {
      cont = TextEditingController(text: currentQuantity.toString());
      productControllers[item.id] = cont;
      setState(() {
        containers.add(_buildContainers(item, cont,i));
        cash c=cash(item.id, item.sellprice);
        cashe.add(c);


      });
    }
  }
  int id=0;
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        print("Enter key pressed");

        // Create a new pro object
        pro p = pro(
          id: id,
          name: 'Product ' + (containers.length + 1).toString(),
          category: '-',
          quantity: 10,
          sell: 10,
          sellprice: 0,
          image: fetchedData[0].image, // assuming fetchedData is available
        );

        // Add the new container
        setState(() {
          addcontainers(p, 0);
          ind=containers.length-1;
          id++;
        });

      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {

          if(ind>=0) {

            Widget w= containers[ind-1];
            Widget w1= containers[ind];

            containers.removeAt(ind-1);
             containers.add(w);


            ind--;
          }

        });

      }

    }
  }

  void updc(int id,double price){
   for(int i=0;i<cashe.length;i++){
     if(cashe[i].id==id){
       cashe[i].price=price;
     }
   }
  }
  double sum(){
    double s=0;
    for(int i=0;i<cashe.length;i++){
      s=s+cashe[i].price;
    }
    return s;
  }
  void updateAndReinsertContainer(pro item) {
    setState(() {
      // Ensure the TextEditingController is correctly initialized
      TextEditingController? cont = productControllers[item.id];
      if (cont == null) {
        cont = TextEditingController(text: productQuantities[item.id]?.toString() ?? '1');
        productControllers[item.id] = cont;
      }

      // Find the index of the container in the list
      int index = containers.indexWhere((widget) {
        // This assumes you have some way to identify the widget
        // For example, you can use a unique key or identifier
        if (widget is Row) {
          // Check if the Row contains the specific item
          // Adjust this logic based on your actual implementation
          final rowChildren = (widget as Row).children;
          return rowChildren.any((child) {
            if (child is Column) {
              final texts = (child as Column).children;
              return texts.any((textWidget) {
                return textWidget is Text && textWidget.data == item.name;
              });
            }
            return false;
          });
        }
        return false;
      });

      if (index != -1) {
        // Remove the old container
        containers.removeAt(index);

        // Update the quantity and the container
        productQuantities[item.id] = int.tryParse(cont.text) ?? 1;
        productContainers[item.id] = _buildContainer(item, cont,0);

        // Insert the updated container at the same index
        containers.insert(index, productContainers[item.id]!);
      } else {
        // Optionally handle the case where the container was not found
        print("Container not found for item ${item.id}");
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    print("Rebuilding the UI...");
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: Color.fromRGBO(224, 227, 231, 1),
            body: Row(
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
                                IconButton(onPressed: (){}, icon:Icon(Icons.account_circle_sharp,size: 40,color: Colors.grey,),),
                                Text("Account",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
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
                                IconButton(onPressed: (){Navigator.of(context).pushNamed('product');}, icon:Icon(Icons.space_dashboard_rounded,size: 40,color: Colors.grey,),),
                                Text("Products",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
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
                                IconButton(onPressed: (){}, icon:Icon(Icons.shopping_cart_outlined,size: 40,color: Colors.grey,),),
                                Text("Purshased",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
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
                                IconButton(onPressed: (){}, icon:Icon(Icons.attach_money_outlined,size: 40,color: Colors.grey,),),
                                Text("Transactions",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
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
                                }, icon:Icon(Icons.people_alt_outlined,size: 40,color: Colors.grey,),),
                                Text("Employees",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
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
                                IconButton(onPressed: (){}, icon:Icon(Icons.settings,size: 40,color: Colors.grey,),),
                                Text("Settings",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sell',
                          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: TextFormField(
                                                controller: conrol,
                                                onChanged:(value){
                                                  setState(() {
                                                   _searchData(value);
                                                  });


                                                },
                                                decoration: InputDecoration(
                                                  suffixIcon: Icon(
                                                    Icons.search_sharp,
                                                    size: 30.0,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          224, 227, 231, 1),
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          224, 227, 231, 1),
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                  ),
                                                  hintText: 'Search employees',
                                                  helperStyle: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color.fromRGBO(
                                                        87, 99, 108, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.qr_code_scanner,
                                                  size: 35),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.list, size: 35),
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.print_rounded, size: 35),
                                          ),
                                          SizedBox(width: 5),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                    Flexible(
                                      child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                        Expanded(child: ListView.builder(
                                            itemCount: rows.length,
                                            itemBuilder:(context,index){
                                              return Column(
                                                children: [
                                                  rows[index],
                                                  SizedBox(height: 15,)
                                                ],
                                              );


                                            }

                                        )

                                        )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Cashier',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: ListView.builder(
                                            itemCount: containers.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  containers[index],
                                                  SizedBox(height: 20),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Container(
                                          height: 300,
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
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${containers.length} Items',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 20,
                                                        color: Color.fromRGBO(
                                                            36, 150, 137, 1),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Subtotal: 3900',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                          FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text('Discount',
                                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),)
                                                  ],
                                                ),
                                                Text("Total ${sum()}",
                                                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),),
                                                SizedBox(
                                                  height: 40,
                                                  child: ListView(
                                                    children :[ ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor: Color.fromRGBO(36, 150, 137, 1),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                                      ),
                                                      onPressed: () {
                                                       setState(() {
                                                         containers.clear();
                                                         productControllers.clear();
                                                         productQuantities.clear();
                                                         productContainers.clear();
                                                         cashe.clear();
                                                       });
                                                      },
                                                      child: Text(
                                                        'Go to Payment',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    ]
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        RawKeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                print('Enter key pressed inside RawKeyboardListener');
              }
            }
          },
          child: SizedBox.shrink(),
        ),
    RawKeyboardListener(
    focusNode: _focusNode,
    autofocus: true,
    onKey: (RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
    print('Enter key pressed inside RawKeyboardListener');
    }
    }
    },
    child: SizedBox.shrink(),
    ),
      ],
    );
  }
  FocusNode widgetFocusNode = FocusNode();
  FocusNode _focusNode = FocusNode();


  @override
  void dispose() {
    // Dispose of all the FocusNodes when the widget is disposed
    focusNode.dispose();
    _focusNode.dispose();
    priceFocusNodes.values.forEach((node) => node.dispose());
    priceFocusNodes1.values.forEach((node) => node.dispose());
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    RawKeyboard.instance.removeListener(_handleKeyEvents);
    super.dispose();
  }
  String barcode = '';
  FocusNode focusNode = FocusNode();
  void onBarcodeScanned(String scannedCode) {
    pro? scannedProduct;
    for (pro p in fetchedData) {
      if (p.id == int.tryParse(scannedCode)) {
        scannedProduct = p;
        break; // Exit the loop once the product is found
      }
    }

    if (scannedProduct != null) {
      setState(() {
        if (productQuantities.containsKey(scannedProduct?.id)) {
          // Increment product quantity
          productQuantities[scannedProduct!.id] = productQuantities[scannedProduct.id]! + 1;

          // Update the TextEditingController to reflect the new quantity
          productControllers[scannedProduct.id]?.text = productQuantities[scannedProduct.id].toString();
          int i = productQuantities[scannedProduct.id] ?? 0;

          // Rebuild the container with the updated quantity
          updateAndReinsertContainer(scannedProduct);
          updc(scannedProduct.id, scannedProduct.sellprice*i);
        } else {
          // Initialize the product quantity and add the container
          productQuantities[scannedProduct!.id] = 1;
          addcontainer(scannedProduct, 1);
          ind=containers.length-1;
          // Pass the initial quantity
        }
      });
    } else {
      print("Product not found for barcode: $scannedCode");
    }
  }

}

class cash {
  late int id;
  late double price;


  cash(int id,double price){
    this.id=id;
    this.price=price;
  }
}

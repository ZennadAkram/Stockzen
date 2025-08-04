import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stockzen/att.dart';
import 'package:stockzen/emp.dart';
import 'package:stockzen/sqllite.dart';
class Attendanc extends StatefulWidget {
  const Attendanc({super.key});

  @override
  State<Attendanc> createState() => _AttendancState();
}

class _AttendancState extends State<Attendanc> {
  DateTime _currentDate = DateTime.now();

  void _changeDateByDays(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
  }
  String _formatDate(DateTime date) {
    DateTime today = DateTime.now();
    if (_isSameDate(today, date)) {
      return 'Today, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    } else {
      return '${_getDayName(date)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  // Helper method to check if two dates are the same
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // Get the name of the day (e.g., Monday, Tuesday, etc.)
  String _getDayName(DateTime date) {
    List<String> days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1]; // Correctly handle weekday index (1=Monday to 7=Sunday)
  }

  // Get the name of the month (e.g., January, February, etc.)
  String _getMonthName(int month) {
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  late Future<List<emp>> prod;
  late Future<List<att>> attend;
  late List<att> at;
  late List<emp> fetchedData;
  late int i=0;
  Future<void> fetchAndInitialize() async {
    prod = fetch();
    attend = fetchat();
    at = await attend;
    fetchedData = await prod;

    print('Fetched attendance data: $at');
    print('Fetched employee data: $fetchedData');

    setState(() {
      rows.clear();
      for (att a in at) {
        print('${a.date} ${a.id} ${a.at}');
      }
      for (emp e in fetchedData) {

        String form = "${_currentDate.day.toString().padLeft(2, '0')}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.year}";
        setcolor(e.id, form);
      }
      addRow(fetchedData);
    });
  }

  Future<List<att>> fetchat() async{
    final db=DatabaseHelper();
    return await db.getat();
  }
  Future<List<emp>> fetch() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getItemsemp();
  }
  @override
  void initState() {
    super.initState();
    fetchAndInitialize();

  }

List<Widget> rows =[];
  Map<String, Color> buttonColors = {};
  void setcolor(int id, String form) {
    for (att a in at) {
      if (a.id == id && a.date == form) {
        if (a.at == 'P') {
          updateButtonColor(id, a.at, Color.fromRGBO(36, 150, 137, 1));
        } else if (a.at == 'A') {
          updateButtonColor(id, a.at, Color.fromRGBO(255, 89, 99, 1));
        } else if (a.at == 'L') {
          updateButtonColor(id, a.at, Color.fromRGBO(249, 207, 88, 1));
        }
      }
    }
  }
  void updateButtonColor(int id, String pressedButtonType, Color newColor) {
    setState(() {
      // Change the pressed button's color
      buttonColors['${id}_$pressedButtonType'] = newColor;

      // Reset the other buttons' colors in the same container
      if (pressedButtonType != 'P') {
        buttonColors['${id}_P'] = Color.fromRGBO(224, 227, 231, 1); // Default color
      }
      if (pressedButtonType != 'A') {
        buttonColors['${id}_A'] = Color.fromRGBO(224, 227, 231, 1); // Default color
      }
      if (pressedButtonType != 'L') {
        buttonColors['${id}_L'] = Color.fromRGBO(224, 227, 231, 1); // Default color
      }

    });

  }

  void addRow(List<emp> fetchData) {
    if (fetchData.isEmpty) return;

    int itemsInRow = fetchData.length > 5 ? 5 : fetchData.length;

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int j = 0; j < itemsInRow; j++)
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4.0,
                    color: Color(0x33000000),
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(14),
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.memory(fetchData[j].imageBytes,fit:BoxFit.cover ,)
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      fetchData[j].name,
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(width: 10),
                      Container(
                        height: 55,
                        width: 55,
                        child: ElevatedButton(
                          onPressed: () async {

                            updateButtonColor(fetchData[j].id, 'P', Color.fromRGBO(36, 150, 137, 1));

                            String form = "${_currentDate.day.toString().padLeft(2, '0')}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.year}";
                            final db=DatabaseHelper();
                            if(await db.checkdate(form, fetchData[j].id)){
                              await db.update(fetchData[j].id, 'P', form);
                            }else{
                              await db.insertat(fetchData[j].id, 'P', form);
                            }
                            fetchAndInitialize();

                          },
                          child: Center(
                            child: Text(
                              'P',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColors['${fetchData[j].id}_P'] ?? Color.fromRGBO(224, 227, 231, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        height: 55,
                        width: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            updateButtonColor(fetchData[j].id, 'A', Color.fromRGBO(255, 89, 99, 1));
                            String form = "${_currentDate.day.toString().padLeft(2, '0')}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.year}";
                            final db=DatabaseHelper();
                            if(await db.checkdate(form, fetchData[j].id)){
                            await db.update(fetchData[j].id, 'A', form);
                            }else{
                            await db.insertat(fetchData[j].id, 'A', form);
                            }
                            fetchAndInitialize();
                          },
                          child: Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColors['${fetchData[j].id}_A'] ?? Color.fromRGBO(224, 227, 231, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        height: 55,
                        width: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            updateButtonColor(fetchData[j].id, 'L', Color.fromRGBO(249, 207, 88, 1));
                            String form = "${_currentDate.day.toString().padLeft(2, '0')}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.year}";
                            final db=DatabaseHelper();
                            if(await db.checkdate(form, fetchData[j].id)){
                            await db.update(fetchData[j].id, 'L', form);
                            }else{
                            await db.insertat(fetchData[j].id, 'L', form);
                            }
                            fetchAndInitialize();
                          },
                          child: Center(
                            child: Text(
                              'L',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColors['${fetchData[j].id}_L'] ?? Color.fromRGBO(224, 227, 231, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );

    if (fetchData.length > itemsInRow) {
      addRow(fetchData.sublist(itemsInRow));
    }
  }

  bool _isToday() {
    final now = DateTime.now();
    return _currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day;
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
                              IconButton(onPressed: (){Navigator.of(context).pushNamed('sales');}, icon:Icon(Icons.check_circle_outline_rounded,size: 40,color: Colors.grey,),),
                              Text("Sell",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
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
                                Navigator.of(context).pushNamed('product');
                              }, icon:Icon(Icons.space_dashboard_rounded,size: 40,color: Colors.grey,),),
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
                              IconButton(onPressed: (){}, icon:Icon(Icons.settings,size: 40,color: Colors.grey,),),
                              Text("Settings",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)
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
                              Text('Attendance',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Button to go to the previous day
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios,color: Color.fromRGBO(36, 150, 137, 1),),
                                    onPressed: () {

                                      _changeDateByDays(-1);
                                    buttonColors.clear();
                                    fetchAndInitialize();
                                    }

                                  ),
                                  // Display the current date between the arrows
                                  Text(

                                    _formatDate(_currentDate),
                                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Color.fromRGBO(36, 150, 137, 1)),
                                  ),
                                  // Button to go to the next day
                                  if (!_isToday())
                                    IconButton(
                                      icon: Icon(Icons.arrow_forward_ios, color: Color.fromRGBO(36, 150, 137, 1)),
                                      onPressed: () {
                                        _changeDateByDays(1);
                                        buttonColors.clear();
                                        fetchAndInitialize();
                                      },
                                    ),
                                ],
                              ),
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

                                        ),
                                      ),

                                    ),
                                    SizedBox(width: 50,),
                                    ElevatedButton(onPressed: (){

                                    },style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(249, 207, 88, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),

                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.pen,size: 25,color: Colors.black,),
                                            Text('Records',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w700,color: Colors.black),)
                                          ],
                                        )),
                                    SizedBox(width: 50,),
                                    ElevatedButton(onPressed: (){
                                      Navigator.of(context).pushNamed('employee');
                                    },style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(56, 150, 137, 1),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),

                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.person_solid,size: 25,color: Colors.black,),
                                            Text(' Employees',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.black),)
                                          ],
                                        ))
                                  ],
                                )
                            ),
                          ),
                        ),

                        Expanded(child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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

                              ),
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
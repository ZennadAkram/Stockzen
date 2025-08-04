import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stockzen/att.dart';
import 'package:stockzen/emp.dart';
import 'package:stockzen/sqllite.dart';
class record extends StatefulWidget {
  const record({super.key});

  @override
  State<record> createState() => _recordState();
}

class _recordState extends State<record> {
  late Future<List<emp>> prod;
  late Future<List<att>> attend;
  late List<att> at;
   List<emp> fetchedData=[];
  late int i=0;
  Future<void> fetchAndInitialize() async {
    prod = fetch();
    attend = fetchat();
    at = await attend;
    fetchedData = await prod;

    print('Fetched attendance data: $at');
    print('Fetched employee data: $fetchedData');

    setState(() {

           addContainers(fetchedData);
    });
  }
List<bool> li=[];
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
  List<Widget> containers = [];
  void addContainers(List<emp> fetchedData) {
    li.clear(); // Clear previous states
    setState(() {
      for (int index = 0; index < fetchedData.length; index++) {
        li.add(true); // Initialize li with false for each entry
      }
    });
  }



  int calc(int id){
    int i=0;
    for (att a in at){
      if(a.id==id) {
        if (a.at == 'P' || a.at == 'L') {
          i++;
        }
      }
    }
    return i;
  }
  void search(String s){
    for(emp e in fetchedData.toList()){
      if(e.name.toLowerCase().contains(s.toLowerCase())==false){
        fetchedData.remove(e);
      }
    }

}
  List<att> ind(int id){
    List<att> a1=[];
    for (att a in at){
      if(a.id==id){
        a1.add(a);
      }
    }
    return a1;
  }
  double calce(int id,String d){

    for (att a in at){
      if(a.id==id) {
        if (a.at == 'P' && a.date==d  || a.at == 'L' && a.date==d) {
          return 1;
        }
      }
    }
    return 0;
  }
  TextEditingController cont=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                          IconButton(onPressed: (){
                            Navigator.of(context).pushNamed('product');
                          }, icon:Icon(Icons.space_dashboard_rounded,size: 40,color: Color.fromRGBO(255, 255, 255, 1),),),
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
                     Text('Records',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35),)
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
                              controller: cont,
                                keyboardType: TextInputType.number,
                              onChanged: (value){
                                setState(() {
                                  if(cont.text.isNotEmpty){
                                    search(value);
                                  }else{
                                    fetchAndInitialize();
                                  }
                                });


                              }

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
                          Text('Attendance',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600,color: Colors.black),)
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
                Padding(
                    padding: EdgeInsets.all(14),
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
                  height: 70,
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment:CrossAxisAlignment.center ,
                      children: [
                        Expanded(child: Text("Employee",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)),
                        Expanded(child: Text("Check in",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)),
                        Expanded(child: Text("Check out",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)),
                        Expanded(child: Text("Attendances",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)),
                        Expanded(child: Text("Salery",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)),

                      ],
                    ),
                  ),
                ),
                ),
                Expanded(child: Padding(padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child:ListView.builder(
                        itemCount: fetchedData.length, // fetchedData contains the data to display
                        itemBuilder: (context, index) {
                          emp proc = fetchedData[index];

                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [

                                      Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(shape: BoxShape.circle),
                                            child: Image.memory(proc.imageBytes, fit: BoxFit.cover),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            proc.name,
                                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Text(
                                          proc.checkin,
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          proc.checkout,
                                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          calc(proc.id).toString(),
                                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          (calc(proc.id) * proc.salery).toString(),
                                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          li[index]
                                              ? Icons.arrow_drop_up // Up arrow when expanded
                                              : Icons.arrow_drop_down, // Down arrow when collapsed
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            li[index] = !li[index]; // Toggle the expanded state
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if(li[index]==false)
                                SizedBox(
                                  height: 150,

                                  child: ListView.builder(
                                    itemCount:ind(fetchedData[index].id).length,
                                    itemBuilder: (BuildContext context, int innerIndex) {
                                      List<att> a2 =ind(fetchedData[index].id);
                                    return Column(
                                      children: [
                                        Container(
                                          color: Color.fromRGBO(241, 244, 248, 1),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(child:
                                                Text(a2[innerIndex].date,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)
                                                ),
                                                Expanded(child:
                                                Text(fetchedData[index].checkin,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)
                                                ),
                                                Expanded(child:
                                                Text(fetchedData[index].checkout,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)
                                                ),
                                                Expanded(child:
                                                Text(a2[innerIndex].at,style:  TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)
                                                ),
                                                Expanded(child:
                                                Text((fetchedData[index].salery*calce(fetchedData[index].id,a2[innerIndex].date)).toString(),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 25),)
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20,)
                                      ],
                                    );



                                  },),
                                ),


                                SizedBox(height: 20,),
                            ],
                          );
                        },
                      )

                    ),


                  ],
                ),
                ))
              ],
            ),
            ),
          )
        ],
      ),
    );

  }
 
}

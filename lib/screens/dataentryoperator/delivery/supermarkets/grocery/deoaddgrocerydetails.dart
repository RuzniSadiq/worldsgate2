import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart' as u;
import 'package:path/path.dart';
import 'package:worldsgate/helper/responsive_helper.dart';
import 'package:worldsgate/screens/dataentryoperator/cars/deomanagecars.dart';
import 'package:worldsgate/screens/dataentryoperator/hotels/deomanagehotels.dart';

import '../../../../../widgets/deonavigationdrawer.dart';
import '../../../../../widgets/header.dart';
import '../deoaddsupermarketdetails.dart';

class AddgroceryDetails extends StatefulWidget {
  //const AddgroceryDetails({Key? key}) : super(key: key);

  String? uid;
  String? supermarketid;
  String? grocerycategorypassed;
  AddgroceryDetails(this.uid, this.supermarketid, this.grocerycategorypassed);

  @override
  State<AddgroceryDetails> createState() => _AddgroceryDetailsState();
}

class _AddgroceryDetailsState extends State<AddgroceryDetails> {
  final _formkey = GlobalKey<FormState>();
  var _scaffoldState = new GlobalKey<ScaffoldState>();

  final TextEditingController groceryNameController = TextEditingController();
  final TextEditingController grocerytagController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  //String? grocerycategory;
  String? subcategory;

  var entryList;



  List<String> tags = [];

  // final grocerycategories = [
  //   "Pizza",
  //   "Burger",
  //   "2019",
  //   "2018",
  //   "2017",
  //   "2016",
  //   "2015",
  //   "2014",
  //   "2013",
  //   "2012",
  //   "2011",
  //   "2010",
  // ];

  final subcategoryType = [
    "Free",
    "Paid",
  ];

  DropdownMenuItem<String> buildMenuItem(String place) => DropdownMenuItem(
        value: place,
        child: Text(
          place,
          style: const TextStyle(fontSize: 16.0),
        ),
      );

  bool _isLoading = true;

  bool _isMainUploading = false;
  bool _isOtherUploading = false;

  FilePickerResult? result;
  String? file;
  UploadTask? task;
  var coverImageLink;
  List<Uint8List> coverImage = [];

  Future selectFileandUpload() async {
    print('OS: ${u.Platform.operatingSystem}');
    try {
      result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: false);
      setState(() => result = result);
      String filename = basename(result!.files.single.name);
      setState(() => file = filename);

      if (result == null) {
        print("Result is null!");
      }

      if (result != null) {
        try {
          print("Start of upload file method");
          Uint8List uploadfile = result!.files.single.bytes!;
          setState(() {
            coverImage.add(uploadfile);
          });
          String filename = basename(result!.files.single.name);

          //final fileName = basename(file!.path);
          final destination = '/groceryimages/grocerymain/$filename';
          print("The destination is $destination");

          final ref = FirebaseStorage.instance.ref(destination);
          task = ref.putData(uploadfile);
          setState(() {
            _isMainUploading = true;
          });
          setState(() {});
          print("Total bytes $task");
          print("Total bytes ${task!.snapshot.totalBytes}");

          if (task == null) return;
          final snapshot = await task!.whenComplete(() {
            setState(() {
              _isMainUploading = false;
            });
          });
          final urlDownload = await snapshot.ref.getDownloadURL();

          print('Download-Link: $urlDownload');

          coverImageLink = urlDownload;

          setState(() => coverImageLink = urlDownload);
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  FilePickerResult? otherResult;
  String? otherFile;
  UploadTask? otherTask;
  var otherImageLink;
  List<Uint8List> otherImage = [];
  List<String> OtherHotelImagesUrl = [];

  List<File>? files;

  String? cusname;
  String? role;
  String? grocerycategoryid;


  _uploadgroceryData() async {
    String newgroceryId = FirebaseFirestore.instance.collection('supermarkets').doc(widget.supermarketid).collection('grocerycategory').doc(grocerycategoryid).collection('grocery').doc().id;


    print(grocerycategoryid);
    try {
      await FirebaseFirestore.instance.collection('supermarkets').doc(widget.supermarketid).collection('grocerycategory').doc(grocerycategoryid).collection('grocery').doc(newgroceryId).set({
        'name': groceryNameController.text,
        //'grocerycategory': widget.grocerycategorypassed,
        'tags': tags,
        'price': double.parse(priceController.text),
        'description': descriptionController.text,
        'datecreated': DateTime.now(),
        'dataentryuid': widget.uid,
        'coverimage': coverImageLink,
        'groceryid': newgroceryId,
      });
    } catch (e) {
      print(e);
    }
  }




  getname() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((myDocuments) {
          setState(() {
            cusname = myDocuments.data()!['name'].toString();
            role = myDocuments.data()!['role'].toString();

          });

    });
  }



  getyoo() async {
    await FirebaseFirestore.instance
        .collection('supermarkets').doc(widget.supermarketid).collection('grocerycategory')
        .where('name', isEqualTo: widget.grocerycategorypassed)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {

        setState(() {
          grocerycategoryid = doc['grocerycategoryid'].toString();

        });

      })
    });
  }

  @override
  void initState() {
    super.initState();
    getname();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
    getyoo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldState,
        drawer: new DeoNavigationDrawer(widget.uid),
        backgroundColor: Color(0xFF000000),
        body: (_isLoading == true)
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ResponsiveWidget(
                      mobile: addgroceryDetailsContainer(context, "mobile"),
                      tab: addgroceryDetailsContainer(context, "tab"),
                      desktop: addgroceryDetailsContainer(context, "desktop"),
                    ),
                  ),
                  Positioned(
                      left: 0.0,
                      top: 0.0,
                      right: 0.0,
                      child: Container(
                          child: VendomeHeader(
                            drawer: _scaffoldState,
                            cusname: cusname,
                            cusaddress: "",
                            role: role,
                          ))),
                ],
              ),
      ),
    );
  }

  List<Widget> newbuilder() {
    List<Widget> m = [];
    for (int i = 0; i < tags.length; i++) {


      m.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child:

          Padding(
            padding: const EdgeInsets.all(4.0),
            child: RichText(
              maxLines: 5,
              text: TextSpan(children: [

                TextSpan(
                  text: "${tags[i].toString()}",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),

                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.bottom,
                  child: InkWell(
                    onTap: (){
                         setState(() {
                        tags.remove(
                            tags[i]);
                      });
                    },
                    child: Icon(
                        Icons.close,

                        color: Colors.red,
                        size: 17
                    ),
                  ),
                ),
              ]),
            ),
          ),

        ),
      ));

    }
    return m;
}

  Container addgroceryDetailsContainer(BuildContext context, String device) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.25,
          vertical: MediaQuery.of(context).size.height * 0.2,
        ),
        child: Column(
          children: [
            Container(
              child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: groceryNameController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Color(0xFFdb9e1f),
                              ),
                              onPressed: () {
                                groceryNameController..text = "";
                              }),
                          hintText: "Enter grocery name",
                          labelText: "grocery Name",
                          hintStyle: TextStyle(color: Colors.white70),
                          labelStyle:
                              new TextStyle(color: Colors.white70, height: 0.1),
                          enabled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: Color(0xFFdb9e1f)),
                          ),
                        ),
                        validator: (value) {
                          if (value!.length == 0) {
                            return "grocery name cannot be empty";
                          }
                        },
                        onSaved: (value) {
                          groceryNameController.text = value!;
                        },
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(
                        height: 20,
                      ),





                      //
                      // Container(
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //     children: [
                      //       Expanded(
                      //         child: DropdownButtonFormField(
                      //             decoration: InputDecoration(
                      //               hintText: "grocery Category",
                      //               hintStyle:
                      //                   TextStyle(color: Colors.white70),
                      //               labelText: 'grocery Category',
                      //               labelStyle: TextStyle(
                      //                   color: Colors.white70, height: 0.1),
                      //               enabled: true,
                      //               enabledBorder: UnderlineInputBorder(
                      //                 borderSide: new BorderSide(
                      //                     color: Colors.white70),
                      //               ),
                      //               focusedBorder: UnderlineInputBorder(
                      //                 borderSide: new BorderSide(
                      //                     color: Color(0xFFdb9e1f)),
                      //               ),
                      //             ),
                      //             dropdownColor: Color(0xFF000000),
                      //             //focusColor: Color(0xFFdb9e1f),
                      //             style: TextStyle(color: Colors.white),
                      //             isExpanded: true,
                      //             value: grocerycategory,
                      //             items: grocerycategories.map(buildMenuItem).toList(),
                      //             onChanged: (value) => setState(() {
                      //                   grocerycategory = value as String?;
                      //                 })),
                      //       ),
                      //
                      //       // Expanded(
                      //       //   child: Padding(
                      //       //       padding: const EdgeInsets.only(
                      //       //           left: 8.0),
                      //       //       child: DropdownButtonFormField(
                      //       //           decoration: InputDecoration(
                      //       //             hintText: "Type of sub category",
                      //       //             hintStyle:
                      //       //                 TextStyle(color: Colors.white70),
                      //       //             labelText: 'Sub Category',
                      //       //             labelStyle: TextStyle(
                      //       //                 color: Colors.white70, height: 0.1),
                      //       //             enabled: true,
                      //       //             enabledBorder: UnderlineInputBorder(
                      //       //               borderSide: new BorderSide(
                      //       //                   color: Colors.white70),
                      //       //             ),
                      //       //             focusedBorder: UnderlineInputBorder(
                      //       //               borderSide: new BorderSide(
                      //       //                   color: Color(0xFFdb9e1f)),
                      //       //             ),
                      //       //           ),
                      //       //           dropdownColor: Color(0xFF000000),
                      //       //           //focusColor: Color(0xFFdb9e1f),
                      //       //           style: TextStyle(color: Colors.white),
                      //       //           isExpanded: true,
                      //       //           value: subcategory,
                      //       //           items: subcategoryType
                      //       //               .map(buildMenuItem)
                      //       //               .toList(),
                      //       //           onChanged: (value) => setState(() {
                      //       //                 this.subcategory = value as String?;
                      //       //               }))),
                      //       // ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),

                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: priceController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Color(0xFFdb9e1f),
                              ),
                              onPressed: () {
                                priceController..text = "";
                              }),
                          hintText: "Enter price",
                          labelText: "Price",
                          hintStyle: TextStyle(color: Colors.white70),
                          labelStyle:
                              new TextStyle(color: Colors.white70, height: 0.1),
                          enabled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: Color(0xFFdb9e1f)),
                          ),
                        ),
                        validator: (value) {
                          if (value!.length == 0) {
                            return "Price cannot be empty";
                          }
                        },
                        onSaved: (value) {
                          priceController.text = value!;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        maxLines: null,
                        controller: descriptionController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Color(0xFFdb9e1f),
                              ),
                              onPressed: () {
                                descriptionController..text = "";
                              }),
                          hintText: "Enter grocery description",
                          labelText: "grocery Description",
                          hintStyle: TextStyle(color: Colors.white70),
                          labelStyle:
                          new TextStyle(color: Colors.white70, height: 0.1),
                          enabled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                            new BorderSide(color: Color(0xFFdb9e1f)),
                          ),
                        ),
                        validator: (value) {
                          if (value!.length == 0) {
                            return "grocery description cannot be empty";
                          }
                        },
                        onSaved: (value) {
                          descriptionController.text = value!;
                        },
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: grocerytagController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Color(0xFFdb9e1f),
                              ),
                              onPressed: () {
                                grocerytagController..text = "";
                              }),
                          hintText: "Enter grocery tag",
                          labelText: "grocery Tag",
                          hintStyle: TextStyle(color: Colors.white70),
                          labelStyle:
                          new TextStyle(color: Colors.white70, height: 0.1),
                          enabled: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                            new BorderSide(color: Color(0xFFdb9e1f)),
                          ),
                        ),
                        validator: (value) {
                          if (value!.length == 0) {
                            return "grocery tag cannot be empty";
                          }
                        },
                        // onSaved: (value) {
                        //   grocerytagController.text = value!;
                        // },
                        onFieldSubmitted: (value){
                          //  grocerytagController.text = value!;
                          setState(() {
                            tags.add(
                                value);

                          });

                        },
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      Wrap(
                        direction: Axis.horizontal,
                        children: newbuilder(),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "grocery Cover Photo",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 270.0,
                          height: 50.0,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFF000000),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    side: BorderSide(color: Color(0xFFdb9e1f))),
                                side: BorderSide(
                                  width: 2.5,
                                  color: Color(0xFFdb9e1f),
                                ),
                                textStyle: const TextStyle(fontSize: 16)),
                            onPressed: () {
                              selectFileandUpload();
                            },
                            icon: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 20,
                            ), //icon data for elevated button
                            label: Text(
                              "grocery Cover Photo",
                              style: TextStyle(color: Colors.white),
                            ),
                            /*child: const Text(
                                            'Hotel Cover Photo',
                                            style: TextStyle(
                                                color: Colors.white),
                                          ),*/
                          ),
                        ),
                      ),
                      coverImage.length != 0
                          ? Container(
                              width: MediaQuery.of(context).size.width / 1.6,
                              height: 160,
                              child: GridView.builder(
                                  itemCount: coverImage.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 7),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: MemoryImage(
                                                      coverImage[index]),
                                                  fit: BoxFit.cover))),
                                    );
                                    //Text('Image : ' + index.toString());
                                  }),
                            )
                          : SizedBox(
                              height: 10,
                            ),

                      /*SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Features",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            hintText: "Car Gear",
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            labelText: 'Gear',
                                            labelStyle: TextStyle(
                                                color: Colors.white70,
                                                height: 0.1),
                                            enabled: true,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.white70),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Color(0xFFdb9e1f)),
                                            ),
                                          ),
                                          dropdownColor: Color(0xFF000000),
                                          //focusColor: Color(0xFFdb9e1f),
                                          style: TextStyle(color: Colors.white),
                                          isExpanded: true,
                                          value: gear,
                                          items: gearType
                                              .map(buildMenuItem)
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                                this.gear = value as String?;
                                              }))),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            hintText: "Car Engine",
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            labelText: 'Engine',
                                            labelStyle: TextStyle(
                                                color: Colors.white70,
                                                height: 0.1),
                                            enabled: true,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.white70),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Color(0xFFdb9e1f)),
                                            ),
                                          ),
                                          dropdownColor: Color(0xFF000000),
                                          //focusColor: Color(0xFFdb9e1f),
                                          style: TextStyle(color: Colors.white),
                                          isExpanded: true,
                                          value: engine,
                                          items: engineType
                                              .map(buildMenuItem)
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                                this.engine = value as String?;
                                              }))),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            hintText: "Car Color",
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            labelText: 'Color',
                                            labelStyle: TextStyle(
                                                color: Colors.white70,
                                                height: 0.1),
                                            enabled: true,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.white70),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Color(0xFFdb9e1f)),
                                            ),
                                          ),
                                          dropdownColor: Color(0xFF000000),
                                          //focusColor: Color(0xFFdb9e1f),
                                          style: TextStyle(color: Colors.white),
                                          isExpanded: true,
                                          value: color,
                                          items: carColor
                                              .map(buildMenuItem)
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                                this.color = value as String?;
                                              }))),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            hintText: "Number of Seats",
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            labelText: 'Seats',
                                            labelStyle: TextStyle(
                                                color: Colors.white70,
                                                height: 0.1),
                                            enabled: true,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.white70),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Color(0xFFdb9e1f)),
                                            ),
                                          ),
                                          dropdownColor: Color(0xFF000000),
                                          //focusColor: Color(0xFFdb9e1f),
                                          style: TextStyle(color: Colors.white),
                                          isExpanded: true,
                                          value: seats,
                                          items: seatsDoorsLuggageCount
                                              .map(buildMenuItem)
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                                this.seats = value as String?;
                                              }))),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            hintText: "Number of Doors",
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            labelText: 'Doors',
                                            labelStyle: TextStyle(
                                                color: Colors.white70,
                                                height: 0.1),
                                            enabled: true,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.white70),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Color(0xFFdb9e1f)),
                                            ),
                                          ),
                                          dropdownColor: Color(0xFF000000),
                                          //focusColor: Color(0xFFdb9e1f),
                                          style: TextStyle(color: Colors.white),
                                          isExpanded: true,
                                          value: doors,
                                          items: seatsDoorsLuggageCount
                                              .map(buildMenuItem)
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                                this.doors = value as String?;
                                              }))),
                                ),
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            hintText: "Number of Luggage",
                                            hintStyle: TextStyle(
                                                color: Colors.white70),
                                            labelText: 'Luggage',
                                            labelStyle: TextStyle(
                                                color: Colors.white70,
                                                height: 0.1),
                                            enabled: true,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.white70),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Color(0xFFdb9e1f)),
                                            ),
                                          ),
                                          dropdownColor: Color(0xFF000000),
                                          //focusColor: Color(0xFFdb9e1f),
                                          style: TextStyle(color: Colors.white),
                                          isExpanded: true,
                                          value: luggage,
                                          items: seatsDoorsLuggageCount
                                              .map(buildMenuItem)
                                              .toList(),
                                          onChanged: (value) => setState(() {
                                                this.luggage = value as String?;
                                              }))),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Wrap(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: device == "mobile"
                                      ? MediaQuery.of(context).size.width * 0.5
                                      : device == "tab"
                                          ? MediaQuery.of(context).size.width *
                                              0.25
                                          : device == "desktop"
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                  child: OtherCarFeatures(
                                    featureText: 'Sensors',
                                    featureValue: featureBoolValue,
                                    featureList: otherFeatures,
                                  ),
                                ),
                                Container(
                                  width: device == "mobile"
                                      ? MediaQuery.of(context).size.width * 0.5
                                      : device == "tab"
                                          ? MediaQuery.of(context).size.width *
                                              0.25
                                          : device == "desktop"
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                  child: OtherCarFeatures(
                                      featureText: 'Bluetooth',
                                      featureValue: featureBoolValue,
                                      featureList: otherFeatures),
                                ),
                                Container(
                                  width: device == "mobile"
                                      ? MediaQuery.of(context).size.width * 0.5
                                      : device == "tab"
                                          ? MediaQuery.of(context).size.width *
                                              0.25
                                          : device == "desktop"
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                  child: OtherCarFeatures(
                                      featureText: 'Camera',
                                      featureValue: featureBoolValue,
                                      featureList: otherFeatures),
                                ),
                                Container(
                                  width: device == "mobile"
                                      ? MediaQuery.of(context).size.width * 0.5
                                      : device == "tab"
                                          ? MediaQuery.of(context).size.width *
                                              0.25
                                          : device == "desktop"
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                  child: OtherCarFeatures(
                                      featureText: 'Safety',
                                      featureValue: featureBoolValue,
                                      featureList: otherFeatures),
                                ),
                                Container(
                                  width: device == "mobile"
                                      ? MediaQuery.of(context).size.width * 0.5
                                      : device == "tab"
                                          ? MediaQuery.of(context).size.width *
                                              0.25
                                          : device == "desktop"
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.1,
                                  child: OtherCarFeatures(
                                      featureText: 'Mp3/CD',
                                      featureValue: featureBoolValue,
                                      featureList: otherFeatures),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),*/
                      SizedBox(
                        height: 40,
                      ),
                      _isMainUploading || _isOtherUploading
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: SizedBox(
                                  height: 80.0,
                                  width: 80.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFdb9e1f)),
                                  )),
                            )
                          : Container(
                              width: 100.0,
                              height: 50.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color(0xFF000000),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                        side: BorderSide(
                                            color: Color(0xFFdb9e1f))),
                                    side: BorderSide(
                                      width: 2.5,
                                      color: Color(0xFFdb9e1f),
                                    ),
                                    textStyle: const TextStyle(fontSize: 16)),
                                onPressed: () {
                                  //uploadMainFunction(_selectedFile);
                                  //uploadFile();
                                  _uploadgroceryData();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          AddSupermarketDetails(widget.uid)));
                                },
                                child: const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}


import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:garaj/view/screen/home_screen_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:garaj/model/reservation.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class GenerateScreen extends StatefulWidget {
  final String reservationId;
  final Reservation reservation;

  const GenerateScreen(
      {Key? key, required this.reservationId, required this.reservation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  GlobalKey globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My reservation'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:  reservationRef
            .doc(widget.reservationId).snapshots(),
        builder: (context, snapshot) {
          Map<dynamic, dynamic> res =
          json.decode(json.encode(snapshot.data!.data()));
          Reservation reservation= Reservation.fromJson(Map<String, dynamic>.from(res));
          print('aaaa ${reservation.status}');
          if (snapshot.hasData){
            return _contentWidget(reservation.status);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  _contentWidget(String? status) {
    const bodyHeight = 500;
    return Container(
      color: const Color(0xFFFFFFFF),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: widget.reservationId,
                  size: 0.5 * bodyHeight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Park name: ' + widget.reservation.parkName!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Reservation date: ' + widget.reservation.dateTime!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Reservation time: ' + widget.reservation.time!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Reservation status: ' + status!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if(widget.reservation.status=='Accepted')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: Get.theme.primaryColor,
                        onPressed: () {
                          openMap(
                              double.parse(widget.reservation.lat.toString()),
                              double.parse(widget.reservation.lng.toString()));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Navigate to Park',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}

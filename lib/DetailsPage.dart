
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:productdevelopment/DetailPage.dart';

import 'HistoryPage.dart';
import 'ScheduleListPage.dart';



class DetailsPage extends StatefulWidget {
  var request;

  DetailsPage(this.request);

  @override
  _DetailsPageState createState() => new _DetailsPageState(request);
}

class _DetailsPageState extends State<DetailsPage> {
  PageController _pageController;
  int _page = 0;
  var request;

  _DetailsPageState(this.request);

  @override
  void initState() {
    super.initState();
    print("Request id "+request.statusId.toString());
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }


  void navigationTapped(int page) {
    // Animating to the page.
    // You can use whatever duration and curve you like
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 400), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  PageView(
        children: [
           DetailPage(request),
           HistoryPage(request),
           ScheduleListPage(request),
        ],
        onPageChanged: onPageChanged,
        controller: _pageController,
      ),
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Color(0xFF004c4c),

        ), // sets the inactive color of the `BottomNavigationBar`
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all( Radius.circular(0.0) ),
            child: new BottomNavigationBar(
              items: [
                 BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.infoCircle, size: 15,),
                    title: Text('Details')
                ),
                 BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.history, size: 15,),
                    title:  Text('History')
                ),
                if(request.statusId>=5) BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.calendarCheck, size: 15,),
                    title: Text('Schedule')
                )
              ],
              onTap: navigationTapped,
              currentIndex: _page,
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.amberAccent,
            ),
          ),
        ),
      ),
    );
  }
}
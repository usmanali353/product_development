
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'HistoryPage.dart';
import 'SchedulePage.dart';



class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => new _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  PageController _pageController;
  int _page = 0;
  @override
  void initState() {
    super.initState();
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
           HistoryPage(),
           HistoryPage(),
           SchedulePage(),
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
                 BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.calendarCheck, size: 15,),
                    title: Text('Schedule')
                ),
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
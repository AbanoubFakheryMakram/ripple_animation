import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';
import 'new_page.dart';



// ? Ripple animation
// In order to perform our ripple effect, we need to have the starting position
// easiest way to do it is to use rect_getter package


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fab overlay transition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // first initialize the RectGetter library
  // second go to the widget that we want to get its position (start ripple animation from it) and wrap it with RectGetter Widget
  // which tack 2 parameter
  // 1- the created key 
  // 2- the child that we wand to get its position (start ripple animation from it)
  // third create an oject from Rect class to store the position information of wraped widget

  var globalKey = RectGetter.createGlobalKey();
  Rect rect;

  // The ripple animation time (1 second)
  Duration animationDuration = Duration(milliseconds: 500);
  Duration delayTime = Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    // reason of using stack is that the ripple widget will increase to cover the whole screen 
    // so to do that we want to use stack
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(title: Text('Fab overlay transition')),
          body: Center(child: Text('This is first page')),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: RectGetter(
            key: globalKey,
            child: FloatingActionButton(
              onPressed: _onTap,
              child: Icon(Icons.mail_outline),
            ),
          ),
        ),
        _ripple(),
      ],
    );
  }

  // create a false widget to start animation from it
  Widget _ripple() {
    if (rect == null) {
      return Container();
    }

    // has the same position of fab and its shape
    // use AnimatedPosition to transition from a small dot to blue screen go smoothly
    return AnimatedPositioned(
      duration: animationDuration,
      left: rect.left,
      right: MediaQuery.of(context).size.width - rect.right,
      top: rect.top,
      bottom: MediaQuery.of(context).size.height - rect.bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,   // the shape of the ripple
          color: Colors.pink,       // the color of the overlay
        ),
      ),
    );
  }


  void _onTap() {

    // => set rect to be size of fab  (widget)
    setState(() => rect = RectGetter.getRectFromKey(globalKey));           
        
        /*
        we cannot change the size of ripple after we set it to the original one (covering the fab). 
        We need to delay it a bit, to be more specific, 
        we just need a one frame delay. That’s why we will use WidgetsBinding.postFrameCallback.
         */

    // Make delay for one frame to expand the size of the ripple
    WidgetsBinding.instance.addPostFrameCallback((_) {   
       // => expand the ripple size to the logest side * 1.3 to covering whole screen
      setState(() => rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide));  
       // => after delay, go to next page
      Future.delayed(animationDuration + delayTime, goToNextPage); 
    });
  }

  void goToNextPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) {
            return NewPage();
          }
          // set rect = null to remove ripple
        )).then((_) => setState(() => rect = null),
        );
        
  }
}

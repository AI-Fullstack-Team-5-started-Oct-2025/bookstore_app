import 'package:flutter/material.dart';

//  appbar custom

enum AppbarAlign { l, r, c }

PreferredSizeWidget restiApB({
  required String appBarText,
  Color bgc = Colors.white,
  Color fgc = Colors.white,
  PreferredSizeWidget? bottom,
  Widget? leading,
  AppbarAlign align = AppbarAlign.c,
  TextStyle? appBartextstyle,
  List<Widget>? actions,
}) {
  Widget titleWidget;
  switch (align) {
    case AppbarAlign.l:
      titleWidget = (Align(
        alignment: Alignment.centerLeft,
        child: Text(
          appBarText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      break;
    case AppbarAlign.r:
      titleWidget = (Align(
        alignment: Alignment.centerRight,
        child: Text(
          appBarText,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      break;
    default:
      titleWidget = Text(
        appBarText,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
      break;
  }

  return AppBar(
    backgroundColor: bgc,
    foregroundColor: fgc,
    centerTitle: align == AppbarAlign.c,
    title: titleWidget,
    leading: leading,
    bottom: bottom,
    actions: actions,
  );
}

//  button custom

enum ButtonType { eb, tb, ob, ib, fa }

enum ChildType { i, t }

Widget restiButtons({
  required VoidCallback onPressed,
  ButtonType buttonType = ButtonType.eb,
  Color buttonColor = Colors.blue,
  Color? buttonBackgroundColor = Colors.transparent,
  Color? buttonForegroundColor,
  String buttonText = 'Test',
  Color? textColor,
  IconData iconData = Icons.star,
  ChildType childType = ChildType.t,
}) {
  Widget buildChild() {
    switch (childType) {
      case ChildType.t:
        return Text(
          buttonText,
          style: TextStyle(color: textColor ?? Colors.white),
        );
      case ChildType.i:
        return Icon(iconData, color: buttonColor);
    }
  }

  switch (buttonType) {
    case ButtonType.eb:
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          minimumSize: Size(150, 40),
        ),
        child: buildChild(),
      );

    case ButtonType.tb:
      return TextButton(onPressed: onPressed, child: buildChild());

    case ButtonType.ob:
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: buttonBackgroundColor,
          foregroundColor: buttonForegroundColor ?? Colors.white,
          side: BorderSide(color: Colors.black, width: 2),
        ),
        child: buildChild(),
      );
    case ButtonType.ib:
      return IconButton(
        onPressed: onPressed,
        icon: Icon(iconData, color: textColor ?? Colors.black),
        style: IconButton.styleFrom(
          backgroundColor: buttonBackgroundColor ?? Colors.transparent,
          foregroundColor: buttonForegroundColor ?? Colors.white,
        ),
      );
    case ButtonType.fa:
      return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: buttonBackgroundColor,
        foregroundColor: buttonForegroundColor ?? Colors.white,
        child: buildChild(),
      );
  }
}

//  Tabbar presets
Widget restiTabbar(Map<String, IconData> input) {
  return DefaultTabController(
    length: input.length,
    child: TabBar(
      tabs: input.entries.map((e) {
        return Tab(icon: Icon(e.value), text: e.key);
      }).toList(),
    ),
  );
}

  //  Bottom Tabbar
  /*
  bottomNavigationBar: Material(
          // TabBar는 Material 위에 있어야 밑줄/효과가 제대로 나옴
          color: Colors.blue,
          child: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
        */

  //  Snackbar
  /*
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      content: Text('Hello SnackBar!'),
    ),
  );
  */
  
  //  showModalBottomSheet
  /*
  snackbar의 경우 이벤트나 액션을 추가할 수 없고 자동으로 내려가며 크기 제한, 키값이 필요하지만
  showModalBottomSheet의 경우 원하는 만큼 커스텀이 가능하다
  */
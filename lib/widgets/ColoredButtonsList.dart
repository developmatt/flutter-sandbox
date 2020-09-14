import 'package:flutter/material.dart';

class ColoredButtonsList extends StatefulWidget {
  final List<ColoredButtonsListButton> buttonsList;

  ColoredButtonsList(this.buttonsList);

  @override
  _ColoredButtonsListState createState() => _ColoredButtonsListState();
}

class _ColoredButtonsListState extends State<ColoredButtonsList> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.buttonsList.length,
      itemBuilder: (context, index) {
        return ColoredButtonsListButton(
          color: ColoredButtonListColors.nextColor(),
          icon: widget.buttonsList[index].icon,
          onTap: widget.buttonsList[index].onTap,
          text: widget.buttonsList[index].text,
        );
      }
    );
  }
}

class ColoredButtonsListButton extends StatelessWidget {

  final Function onTap;
  final IconData icon;
  final String text;
  final Color color;

  ColoredButtonsListButton({this.onTap, this.icon, this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        alignment: Alignment.centerLeft,
        height: 120.0,
        color: this.color ?? ColoredButtonListColors.nextColor(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(this.icon, color: Colors.white, size: 30.0),
                ),
                Text(
                  this.text.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Icon(Icons.chevron_right, color: Colors.white, size: 30.0),
            )
          ],
        ),
      ),
    );
  }
}

class ColoredButtonListColors {
  static final List<Color> _colors = [
    Color(0xFF3e979b),
    Color(0xFF6db464),
    Color(0xFFf3c14e),
    Color(0xFFf78055),
    Color(0xFFc97694)];
  static int _index = -1;

  static Color nextColor() {
    if(_index < _colors.length - 1) {
      _index++;
    } else {
      _index = 0;
    }
    return _colors[_index];
  }
}
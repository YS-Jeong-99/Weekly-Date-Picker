library weekly_date_picker;

import 'package:flutter/material.dart';
import 'package:week_of_year/week_of_year.dart';
import "package:weekly_date_picker/datetime_apis.dart";

enum FWFontWeight { bold, normal, thin }

class WeeklyDatePicker extends StatefulWidget {
  WeeklyDatePicker({
    Key? key,
    required this.selectedDay,
    required this.changeDay,
    this.weekdayText = 'Week',
    this.weekdays = const ['월', '화', '수', '목', '금', '토', '일'],
    this.backgroundColor = const Color(0xFFFAFAFA),
    this.selectedBackgroundColor = const Color(0xFF2A2859),
    this.selectedDigitColor = const Color(0xFF2A2859),
    this.digitsColor = const Color(0xFF000000),
    this.weekdayTextColor = const Color(0xFF000000),
    this.enableWeeknumberText = false,
    this.weeknumberColor = const Color(0xFFB2F5FE),
    this.weeknumberTextColor = const Color(0xFF000000),
    this.daysInWeek = 7,
    this.textStyle = const TextStyle(
      fontFamily: 'Noto_Sans_KR',
      fontWeight: FontWeight.w500,
      fontSize: 14.0,
      height: 20 / 14,
    ),
  })  : assert(weekdays.length == daysInWeek,
            "weekdays must be of length $daysInWeek"),
        super(key: key);

  /// The current selected day
  final DateTime selectedDay;

  /// Callback function with the new selected date
  final Function(DateTime) changeDay;

  /// Specifies the weekday text: default is 'Week'
  final String weekdayText;

  /// Specifies the weekday strings ['Mon', 'Tue'...]
  final List<String> weekdays;

  /// Background color
  final Color backgroundColor;

  /// Color of the selected digits text
  final Color selectedBackgroundColor;

  /// Color of the unselected digits text
  final Color selectedDigitColor;

  /// Color of the unselected digits text
  final Color digitsColor;

  /// Is the color of the weekdays 'Mon', 'Tue'...
  final Color weekdayTextColor;

  /// Set to false to hide the weeknumber textfield to the left of the slider
  final bool enableWeeknumberText;

  /// Color of the weekday container
  final Color weeknumberColor;

  /// Color of the weekday text
  final Color weeknumberTextColor;

  /// Specifies the number of weekdays to render, default is 7, so Monday to Sunday
  final int daysInWeek;

  final TextStyle textStyle;

  @override
  _WeeklyDatePickerState createState() => _WeeklyDatePickerState();
}

class _WeeklyDatePickerState extends State<WeeklyDatePicker> {
  final DateTime _todaysDateTime = DateTime.now();

  // About 100 years back in time should be sufficient for most users, 52 weeks * 100
  final int _weekIndexOffset = 5200;

  late final PageController _controller;
  late final DateTime _initialSelectedDay;
  late int _weeknumberInSwipe;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _weekIndexOffset);
    _initialSelectedDay = widget.selectedDay;
    _weeknumberInSwipe = widget.selectedDay.weekOfYear;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: widget.backgroundColor,
      child: Row(
        children: <Widget>[
          widget.enableWeeknumberText
              ? Container(
                  padding: EdgeInsets.all(8.0),
                  color: widget.weeknumberColor,
                  child: Text(
                    '${widget.weekdayText} $_weeknumberInSwipe',
                    style: widget.textStyle
                        .apply(color: widget.weeknumberTextColor),
                  ),
                )
              : Container(),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (int index) {
                setState(() {
                  _weeknumberInSwipe = _initialSelectedDay
                      .add(Duration(days: 7 * (index - _weekIndexOffset)))
                      .weekOfYear;
                });
              },
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, weekIndex) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _weekdays(weekIndex - _weekIndexOffset),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a 5 day list of DateButtons
  List<Widget> _weekdays(int weekIndex) {
    List<Widget> weekdays = [];

    for (int i = 0; i < widget.daysInWeek; i++) {
      final int offset = i + 1 - _initialSelectedDay.weekday;
      final int daysToAdd = weekIndex * 7 + offset;
      final DateTime dateTime =
          _initialSelectedDay.add(Duration(days: daysToAdd));
      weekdays.add(_dateButton(dateTime));
    }
    return weekdays;
  }

  Widget _dateButton(DateTime dateTime) {
    final String weekday = widget.weekdays[dateTime.weekday - 1];
    final bool isSelected = dateTime.isSameDateAs(widget.selectedDay);

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.changeDay(dateTime),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            // Bugfix, the transparent container makes the GestureDetector fill the Expanded
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.selectedBackgroundColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    '$weekday',
                    style: widget.textStyle.apply(
                      color: isSelected
                          ? Color(0xFFFAFAFA)
                          : widget.weekdayTextColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    // Border around today's date
                    color: dateTime.isSameDateAs(_todaysDateTime)
                        ? widget.selectedBackgroundColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: widget.backgroundColor,
                    radius: 14.0,
                    child: Text(
                      '${dateTime.day}',
                      style: widget.textStyle.apply(
                          color: isSelected
                              ? widget.selectedDigitColor
                              : widget.digitsColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

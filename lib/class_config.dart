import 'package:flutter/material.dart';

const List<String> lesson = [
  //w1
  '英文',
  '英文',
  '體育',
  '班會',
  '本土',
  '家政',
  '家政',
  //w2
  '地理',
  '地理',
  '數學',
  '數學',
  '國文',
  '歷史',
  '歷史',
  //w3
  '英文',
  '英文',
  '多元選修',
  '多元選修',
  '國文',
  '探究與實作',
  '探究與實作',
  //w4
  '公民',
  '公民',
  '第二外語',
  '體育',
  '數學',
  '數學',
  '生涯規劃',
  //w5
  '國文',
  '國文',
  '彈性學習',
  '彈性學習',
  '社團',
  '生物',
  '生物'
];

const List<TimeOfDay> classTimes = [
  TimeOfDay(hour: 8, minute: 10),
  TimeOfDay(hour: 9, minute: 10),
  TimeOfDay(hour: 10, minute: 10),
  TimeOfDay(hour: 11, minute: 10),
  //rest
  TimeOfDay(hour: 13, minute: 0),
  TimeOfDay(hour: 14, minute: 0),
  TimeOfDay(hour: 15, minute: 10),
  TimeOfDay(hour: 16, minute: 10),
];

List<int> numbersOfClass = List.generate(37, (idx) => idx + 1);

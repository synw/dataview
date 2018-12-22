import 'dart:io';
import 'package:flutter/material.dart';

class DirectoryItem {
  final dynamic item;
  final Directory directory;
  final String filename;
  final Icon icon;
  final String type;

  DirectoryItem(this.item, this.directory, this.filename, this.icon, this.type);
}

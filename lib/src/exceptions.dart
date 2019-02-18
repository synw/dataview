class FileNotFound implements Exception {
  FileNotFound(this.cause);
  String cause;
}

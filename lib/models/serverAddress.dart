class Config {
  // Default server address
  static String serverAddress = "http://192.168.0.32/fitbackend";

  static void setServerAddress(String address) {
    serverAddress = address;
  }

  static String endpoint(String path) {
    return "$serverAddress/$path";
  }
}
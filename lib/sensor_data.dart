class SensorData {
  String bluetoothAddress; // Where the tire talks to the phone
  String code; // The tire’s name (like FL or RR)
  bool isBatteryOk; // Is the tire’s battery happy?
  bool isPressureWarning; // Is the pressure too high or low?
  bool isTempWarning; // Is the temperature too hot?
  bool isXieYa; // A special check (we’ll figure this out later!)
  double pressure; // How full the tire is (in psi)
  double pressureMax; // The max pressure it can handle
  double pressureMin; // The min pressure it needs
  int rssi; // Signal strength (how loud the tire talks)
  double tempMax; // The max temperature it can handle
  int temperature; // How warm the tire is (in °C)
  int txPower; // How strong the tire’s radio is
  String uuid; // A unique tire ID

  // This part sets up the tire data with default values
  SensorData({
    this.bluetoothAddress = '',
    this.code = '',
    this.isBatteryOk = false,
    this.isPressureWarning = false,
    this.isTempWarning = false,
    this.isXieYa = false,
    this.pressure = 0.0,
    this.pressureMax = 0.0,
    this.pressureMin = 0.0,
    this.rssi = 0,
    this.tempMax = 0.0,
    this.temperature = 0,
    this.txPower = 0,
    this.uuid = '',
  });

  // This magic turns a message into a tire data toy
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      bluetoothAddress: json['bluetoothAddress'] as String? ?? '',
      code: json['code'] as String? ?? '',
      isBatteryOk: json['isBatteryOk'] as bool? ?? false,
      isPressureWarning: json['isPressureWarning'] as bool? ?? false,
      isTempWarning: json['isTempWarning'] as bool? ?? false,
      isXieYa: json['isXieYa'] as bool? ?? false,
      pressure: (json['pressure'] as num?)?.toDouble() ?? 0.0,
      pressureMax: (json['pressureMax'] as num?)?.toDouble() ?? 0.0,
      pressureMin: (json['pressureMin'] as num?)?.toDouble() ?? 0.0,
      rssi: json['rssi'] as int? ?? 0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 0.0,
      temperature: json['temperature'] as int? ?? 0,
      txPower: json['txPower'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
    );
  }

  // This turns the tire data back into a message
  Map<String, dynamic> toJson() => {
    'bluetoothAddress': bluetoothAddress,
    'code': code,
    'isBatteryOk': isBatteryOk,
    'isPressureWarning': isPressureWarning,
    'isTempWarning': isTempWarning,
    'isXieYa': isXieYa,
    'pressure': pressure,
    'pressureMax': pressureMax,
    'pressureMin': pressureMin,
    'rssi': rssi,
    'tempMax': tempMax,
    'temperature': temperature,
    'txPower': txPower,
    'uuid': uuid,
  };
}
class Channel {
  final String name;
  final String secretKey;

  Channel({required this.name, required this.secretKey});

  Map<String, dynamic> toJson() => {
        'name': name,
        'secretKey': secretKey,
      };

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      name: json['name'],
      secretKey: json['secretKey'],
    );
  }
}

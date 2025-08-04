class att{
  int id;
  String at;
  String date;
  att({
    required this.id,
    required this.at,
    required this.date

});
  factory att.fromMap(Map<String, dynamic> map) {
    return att(
    id: map['id'],
    at: map['attend'],
    date: map['date']
    );
  }
}
class Version {
  int major;
  int minor;
  int patch;

  Version({required this.major, required this.minor, this.patch = 0});

  static Version fromString(String version) {
    version = version.trim().substring(1);
    List<String> split = version.split(".");
    return Version(
      major: int.parse(split[0]),
      minor: int.parse(split[1]),
      patch: split.length > 2 ? int.parse(split[2]) : 0,
    );
  }

  @override
  String toString() {
    String str = "";
    str += "v$major";
    str += ".$minor";
    if (patch != 0) str += ".$patch";
    return str;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Version &&
          runtimeType == other.runtimeType &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch;

  @override
  int get hashCode => major.hashCode ^ minor.hashCode ^ patch.hashCode;
}

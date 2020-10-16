const int FLAVOR_DEBUG = -1;
const int FLAVOR_FREE = 0;
const int FLAVOR_PAID = 1;
const int FLAVOR_FDROID = FLAVOR_FREE;

final int FLAVOR = _flavor();

int _flavor() {
  switch(const String.fromEnvironment('FLAVOR', defaultValue: null)) {
    case "FREE":
      return FLAVOR_FREE;
    case "DEBUG":
      return FLAVOR_DEBUG;
    case "PAID":
      return FLAVOR_PAID;
    case "FDROID":
      return FLAVOR_FDROID;
    default:
      return null;
  }
}

class FlavorConfig {
  static String appName() {
    switch(FLAVOR) {
      case FLAVOR_DEBUG:
        return  "DeadlinesDebug";
      case FLAVOR_FREE:
        return  "DeadlinesFree";
      case FLAVOR_PAID:
        return  "DeadlinesPro";
      default:
        throw Exception();
    }
  }
}
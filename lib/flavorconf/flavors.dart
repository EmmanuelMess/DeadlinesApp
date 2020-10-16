const int FLAVOR_DEBUG = -1;
const int FLAVOR_FREE = 0;
const int FLAVOR_PAID = 1;
const int FLAVOR_FDROID = FLAVOR_FREE;

const int FLAVOR = FLAVOR_FDROID;

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
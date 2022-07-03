import "package:google_maps_webservice/geocoding.dart";

//Using a separate file for google maps webservices due to import conflicts
class Geocoding {
  final String apiKey = "AIzaSyBrNPogNWJF7M8FixB5sUaDuQD7MNIWMZs";

  Future<GeocodingResponse?> getPlaceById(String id) async {
    var geocoding = new GoogleMapsGeocoding(apiKey: apiKey);
    var response = await geocoding.searchByPlaceId(id);
    return response;
  }

  Future<GeocodingResponse?> getPlaceByLocation(double lat, double lng) async {
    Location location = new Location(lat: lat, lng: lng);
    var geocoding = new GoogleMapsGeocoding(apiKey: apiKey);
    var response = await geocoding.searchByLocation(location);
    return response;
  }

}








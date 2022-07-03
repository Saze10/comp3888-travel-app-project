import "package:google_maps_webservice/places.dart";

//Using a separate file for google maps webservices due to import conflicts
class Place {
  final String apiKey = "AIzaSyBrNPogNWJF7M8FixB5sUaDuQD7MNIWMZs";

  Future<PlacesSearchResponse?> getNearByLocations(double lat, double lng, double radius, String type) async {
    Location location = new Location(lat: lat, lng: lng);
    var places = new GoogleMapsPlaces(apiKey: apiKey);
    var response = await places.searchNearbyWithRadius(location, radius, type: type);
    return response;
  }

  Future<PlacesSearchResponse?> getPlaceByText(String address) async {
    var place = new GoogleMapsPlaces(apiKey: apiKey);
    var response = await place.searchByText(address);
    return response;
  }

}




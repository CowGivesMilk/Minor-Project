import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:collection';
class Bus {
  int routeId;
  String name;
  List<Node> nodes;
  Bus({required this.routeId, required this.nodes, required this.name});
  void addToNodes(Set<Node> allNodes) {
    for (Node node in nodes) {
      Node? matchingNode = allNodes.lookup(node);
      if (matchingNode != null) {
        matchingNode.addBus(this);
      }
    }
  }
  String key() {
    return name;
  }
}

class Node {
  String name;
  double latitude;
  double longitude;
  Set<Bus> buses;
  Node(
      {required this.name,
      required this.latitude,
      required this.longitude,
      Set<Bus>? buses})
      : buses = buses ?? {};

  @override
  String toString() {
    return '${latitude.toString()}#${longitude.toString()}';
  }

  String toFullString() {
    return 'name: $name latitude: $latitude longitude: $latitude\t';
  }

  void latLong(double? lat, double? long) {
    lat = latitude;
    long = longitude;
  }

  void addBus(Bus bus) {
    buses.add(bus);
  }
}

class Edge {
  Node start;
  Node end;
  double distance;

  Edge({required this.start, required this.end, required this.distance});
}

//Algorithms
String latlongToString(double latitude, longitude) {
  return '${latitude.toString()}#${longitude.toString()}';
}

String edgeStr(double lat1, double long1, double lat2, double long2) {
  return '${latlongToString(lat1, long1)} ==> ${latlongToString(lat2, long2)}';
}

Node findNearestNode(double lat, double long, Map<String, Node> allNodes) {
  double minDistance = double.maxFinite;
  Node res = Node(name: 'Dummy', latitude: 0.0, longitude: 0.0);
  allNodes.forEach(
    (key, value) {
      double latN = 0.0, longN = 0.0;
      value.latLong(latN, longN);
      if (haversine(lat, long, latN, longN) < minDistance) {
        res = value;
      }
    },
  );
  return res;
}
void parseCSV(Map<String, Node> allNodes, Set<Bus> allBuses) {
  List<List<String>> grid = [];
  final filePath = 'assets/output_file.csv';
  final lines = File(filePath).readAsLinesSync();
  for(var line in lines) {
    final values = line.split(';');
    grid.add(values);
  }
  for(int i = 0; i < grid.length; i += 3) {
    Bus bus = Bus(routeId: i, nodes: [], name: 'Bus $i');
    List<Node> routeNodes = [];
    for(int j = 0; j < grid[i].length; j++) {
      String nodeName = grid[i][j];
      if(nodeName.isEmpty) break;
      print('$i $j');
      double nodeLat = double.parse(grid[i+1][j]);
      double nodeLong = double.parse(grid[i+2][j]);
      Node node = Node(name: nodeName, latitude: nodeLat, longitude: nodeLong);
      routeNodes.add(node);
      if(allNodes.containsKey(node.toString())) {
        allNodes[node.toString()]?.buses.add(bus);
      }else {
        allNodes[node.toString()] = node;
        allNodes[node.toString()]?.buses.add(bus);
      }
    }
    bus.nodes.addAll(routeNodes);
    allBuses.add(bus);
  }
}
Future<double> computeDistanceOSM(Node from, Node to) async {
  final String url =
      'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=false';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['routes'][0]['distance'];
    } else {
      throw Exception('Failed to fetch route: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error fetching route: $e');
    return 0.0;
  }
}

double haversine(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadiusKm = 6371.0; // Radius of Earth in kilometers

  // Convert degrees to radians
  double toRadians(double degree) => degree * pi / 180;

  double dLat = toRadians(lat2 - lat1);
  double dLon = toRadians(lon2 - lon1);

  double a = pow(sin(dLat / 2), 2) +
      cos(toRadians(lat1)) * cos(toRadians(lat2)) * pow(sin(dLon / 2), 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c * 1000;
}
List<dynamic> findPath(Node start, Node end, Set<Node> allNodes) {
  Map<Node, List<dynamic>> visited = {}; // To store visited nodes with paths.
  Queue<List<dynamic>> queue = Queue(); // Queue for BFS traversal.

  // Initialize the queue with the start node.
  queue.add([start]);
  visited[start] = [start];

  while (queue.isNotEmpty) {
    List<dynamic> path = queue.removeFirst();
    Node currentNode = path.last;

    // If we reach the end node, return the path.
    if (currentNode == end) {
      return path;
    }

    // Iterate through all buses connected to the current node.
    for (Bus bus in currentNode.buses) {
      for (Node neighbor in bus.nodes) {
        if (!visited.containsKey(neighbor)) {
          // Create a new path including the bus and the neighbor.
          List<dynamic> newPath = List.from(path)
            ..add('Get on ${bus.name}')
            ..add(neighbor);

          // Mark the neighbor as visited and add it to the queue.
          visited[neighbor] = newPath;
          queue.add(newPath);
        }
      }
    }
  }

  // If no path is found, return an empty list.
  return [];
}
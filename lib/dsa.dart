import 'dart:io';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';
//Data Structures
enum Action {
  walk,
  getOnBus,
  changeBus
}
class Bus {
  int routeId;
  String? name;
  List<Node> nodes;
  Bus({required this.routeId, required this.nodes});
  void addToNodes(Set<Node> allNodes) {
    for (Node node in nodes) {
      Node? matchingNode = allNodes.lookup(node);
      if(matchingNode != null) {
        matchingNode.addBus(this);
      }
    }
  }
}
class Node {
  String name;
  double latitude;
  double longitude;
  Set<Bus> busses;
  Node({required this.name, required this.latitude, required this.longitude, Set<Bus>? busses}) : busses = busses ?? {};
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
    busses.add(bus);
  }
}
class Edge {
  Node start;
  Node end;
  double distance;

  Edge({required this.start, required this.end, required this.distance});
}
class PriorityQueue<T> {
  final List<T> _heap = [];
  final Comparator<T> _comparator;

  PriorityQueue(this._comparator);

  void add(T element) {
    _heap.add(element);
    _siftUp(_heap.length - 1);
  }

  T removeFirst() {
    if (_heap.isEmpty) {
      throw StateError('Priority queue is empty');
    }
    T result = _heap.first;
    if (_heap.length > 1) {
      _heap[0] = _heap.removeLast();
      _siftDown(0);
    } else {
      _heap.removeLast();
    }
    return result;
  }

  bool get isEmpty => _heap.isEmpty;

  void _siftUp(int index) {
    while (index > 0) {
      int parent = (index - 1) >> 1;
      if (_comparator(_heap[index], _heap[parent]) >= 0) {
        break;
      }
      _swap(index, parent);
      index = parent;
    }
  }

  void _siftDown(int index) {
    int leftChild = (index << 1) + 1;
    while (leftChild < _heap.length) {
      int rightChild = leftChild + 1;
      int smallest = (rightChild < _heap.length && _comparator(_heap[rightChild], _heap[leftChild]) < 0)
          ? rightChild
          : leftChild;
      if (_comparator(_heap[smallest], _heap[index]) >= 0) {
        break;
      }
      _swap(index, smallest);
      index = smallest;
      leftChild = (index << 1) + 1;
    }
  }

  void _swap(int i, int j) {
    T temp = _heap[i];
    _heap[i] = _heap[j];
    _heap[j] = temp;
  }
}
//Algorithms
String latlongToString(double latitude, longitude) {
  return '${latitude.toString()}#${longitude.toString()}';
}
String edgeStr(double lat1, double long1, double lat2, double long2) {
  return '${latlongToString(lat1, long1)} ==> ${latlongToString(lat2, long2)}';
}

int parseNodes(Map<String, Node> allNodes, Set<Bus> allBuses, Map<String, Future<double>> edgesMap) {
  String filePath = "/home/nimes/Minor-Project/assets/output_file.xlsx";
  File file = File(filePath);
  if(!file.existsSync()) {
    print('File doesnot exist');
    return -1;
  }
  var bytes = file.readAsBytesSync();
  //print('${bytes.runtimeType}');
  dynamic excel;
  try {
    excel = Excel.decodeBytes(bytes);
    print('file decoded successfully');
  } catch (e) {
    //bytes.forEach(print);
    print('Error decoding file: $e: E130');
    return -1;
  }
  var sheet = excel.tables['Sheet1'];
  if(sheet == null) {
    print('Sheet is empty.');
    return -1;
  }
  var maxRows = sheet.maxRows;
  var maxCols = sheet.maxColumns;
  for(int row = 0; row < maxRows - 2; row += 3) {
    int busId = 0;
    List<Node> busStops = [];

    for(var col = 0; col < maxCols; col++) {
      bool lastCol = false;
      var nameCell = sheet.row(row)[col];
      var latCell = sheet.row(row+1)[col];
      var longCell = sheet.row(row+2)[col];
      if(sheet.row(row)[col + 1] == null) lastCol = true;
      if (nameCell == null || latCell == null || longCell == null) {
        print('Invalid Cell values' );
        return -1;
      }
      String name = nameCell.toString();
      double latitude = double.parse(latCell.toString());
      double longitude = double.parse(longCell.toString());
      Node thisNode = Node(name: name, latitude: latitude, longitude: longitude);
      allNodes[thisNode.toString()] = thisNode;
      busStops.add(thisNode);
      if(lastCol == true) {
        Node? firstNodeofRow = allNodes[latlongToString(double.parse((sheet.row(row+1)[0]).toString()), double.parse((sheet.row(row+2)[0]).toString()))];
        if(firstNodeofRow == null) {
          print('This must not be possible.');
          return -1;
        }
        edgesMap[edgeStr(latitude, longitude, double.parse(sheet.row(row+1)[0].toString()), double.parse(sheet.row(row+2)[0].toString()))] = computeDistanceOSM(thisNode, firstNodeofRow);
      }else {
        var nextName = sheet.row(row)[col + 1].toString();
        var nextLat = double.parse(sheet.row(row+1)[col+1].toString());
        var nextLong = double.parse(sheet.row(row+2)[col+1].toString());
        Node nextNode = Node(name: nextName, latitude: nextLat, longitude: nextLong);
        String nextNodeInStr = nextNode.toString();
        allNodes[nextNodeInStr] = nextNode;
        edgesMap[nextNodeInStr] = computeDistanceOSM(thisNode, nextNode);
      }
    }
    allBuses.add(Bus(routeId: busId, nodes: busStops));
    busId++;
  }
  //Add busses to Nodes
  
  return 0;
}
Node? findNearestNode(double lat, double long, Map<String, Node> allNodes) {
  double minDistance = double.maxFinite;
  Node? res;
  allNodes.forEach((key, value) {
    double latN = 0.0, longN = 0.0;
    value.latLong(latN, longN);
    if(haversine(lat, long, latN, longN) < minDistance) {
      res = value;
    }
  },);
  return res;
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

class RouteFinder {
  Map<String, Node> allNodes;
  Set<Bus> allBuses;
  Map<String, double> edgeDistances;

  RouteFinder(this.allNodes, this.allBuses, this.edgeDistances);

  List<dynamic> findRoute(double latFrom, double longFrom, double latTo, double longTo) {
    List<dynamic> result = [];

    // Find the nearest nodes to start and end locations
    Node? startNode = allNodes[latlongToString(latFrom, longFrom)] ?? findNearestNode(latFrom, longFrom, allNodes);
    Node? endNode = allNodes[latlongToString(latTo, longTo)] ?? findNearestNode(latTo, longTo, allNodes);

    if (startNode == null || endNode == null) {
      print('Start or End node not found. E240');  //E240
      return [];
    }

    if (startNode != allNodes[latlongToString(latFrom, longFrom)]) {
      result.add(Action.walk);
      result.add(startNode);
    }

    // Shortest path search including bus actions
    List<dynamic>? pathWithActions = dijkstraWithActions(startNode, endNode);

    if (pathWithActions == null) {
      print('No path found between start and end nodes. E253');  //E253
      return [];
    }

    result.addAll(pathWithActions);

    if (endNode != allNodes[latlongToString(latTo, longTo)]) {
      result.add(Action.walk);
    }

    return result;
  }

  List<dynamic>? dijkstraWithActions(Node start, Node end) {
    Map<Node, double> distances = {};
    Map<Node, Node?> previous = {};
    Map<Node, Bus?> usedBus = {};
    PriorityQueue<MapEntry<Node, double>> queue = PriorityQueue(
      (a, b) => a.value.compareTo(b.value),
    );

    for (Node node in allNodes.values) {
      distances[node] = double.infinity;
      previous[node] = null;
      usedBus[node] = null;
    }

    distances[start] = 0;
    queue.add(MapEntry(start, 0));

    while (!queue.isEmpty) {
      Node current = queue.removeFirst().key;

      if (current == end) {
        List<dynamic> pathWithActions = [];
        Node? step = end;
        Bus? currentBus;

        while (step != null) {
          if (previous[step] != null && usedBus[step] != currentBus) {
            if (currentBus != null) {
              pathWithActions.insert(0, currentBus);
              pathWithActions.insert(0, Action.changeBus);
            }
            currentBus = usedBus[step];
          }
          pathWithActions.insert(0, step);
          step = previous[step];
        }

        if (currentBus != null) {
          pathWithActions.insert(0, currentBus);
          pathWithActions.insert(0, Action.getOnBus);
        }

        return pathWithActions;
      }

      for (Bus bus in current.busses) {
        for (Node neighbor in bus.nodes) {
          if (neighbor == current) continue;
          String edgeKey = edgeStr(current.latitude, current.longitude, neighbor.latitude, neighbor.longitude);
          double weight = edgeDistances[edgeKey] ?? haversine(current.latitude, current.longitude, neighbor.latitude, neighbor.longitude);

          double alternativeDistance = distances[current]! + weight;

          if (alternativeDistance < distances[neighbor]!) {
            distances[neighbor] = alternativeDistance;
            previous[neighbor] = current;
            usedBus[neighbor] = bus;
            queue.add(MapEntry(neighbor, alternativeDistance));
          }
        }
      }
    }
    print('No path found');
    return null; // No path found
  }
}


void printPath(List<dynamic> path) {
  for(var item in path) {
    if(item.runtimeType is Action) {
      print(item.toString());
    }else if (item.runtimeType is Node){
      item.toFullString();
    }else {
      print(item);
    }
  }
}

int main() {
  Map<String, Node> allNodes = {};
  Set<Bus> allBuses = {};
  Map<String, double> edgeDistances = {};
  Map<String, Future<double>> edgesMap = {};
  double latFrom = 27.732436;
  double longFrom = 85.3081285;
  double latTo = 27.7156689;
  double longTo = 85.3982037;
  var e = parseNodes(allNodes, allBuses, edgesMap);
  if(e != 0) {
    print('Something went wrong');
    return -1;
  }
  List<dynamic> path = RouteFinder(allNodes, allBuses, edgeDistances).findRoute(latFrom, longFrom, latTo, longTo);
  printPath(path);
  print('Treminated Successfully');
  return 0;
}
// Updated `findRoute` algorithm to match the desired output format.
import 'dsa.dart';

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
      print('Start or End node not found.');
      return [];
    }

    if (startNode != allNodes[latlongToString(latFrom, longFrom)]) {
      result.add(Action.walk);
      result.add(startNode);
    }

    // Shortest path search including bus actions
    List<dynamic>? pathWithActions = dijkstraWithActions(startNode, endNode);

    if (pathWithActions == null) {
      print('No path found between start and end nodes.');
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

    return null; // No path found
  }
}

// Function to parse Excel file into List<Route>
/*
Future<List<dynamic>> parseExcelFile(String filePath) async {
  var bytes = File(filePath).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);
  List<Route> routes = [];

  for (var sheet in excel.tables.keys) {
    var table = excel.tables[sheet]!;
    if (table.rows.isEmpty) continue;

    for (int col = 0; col < table.maxCols; col += 3) {
      String? routeName = table.rows[0][col]?.value;
      if (routeName == null) continue;

      List<Node> nodes = [];
      List<Edge> edges = [];

      for (int row = 1; row < table.maxRows; row++) {
        var nameCell = table.rows[row][col];
        var latCell = table.rows[row][col + 1];
        var lonCell = table.rows[row][col + 2];

        if (nameCell == null || latCell == null || lonCell == null) continue;

        String nodeName = nameCell.value.toString();
        double latitude = double.tryParse(latCell.value.toString()) ?? 0.0;
        double longitude = double.tryParse(lonCell.value.toString()) ?? 0.0;

        Node node = Node(name: nodeName, latitude: latitude, longitude: longitude);
        nodes.add(node);
      }

      // Create edges between consecutive nodes
      for (int i = 0; i < nodes.length - 1; i++) {
        Edge edge = Edge(from: nodes[i], to: nodes[i + 1]);
        edge.distance = await computeDistance(nodes[i], nodes[i + 1]); // Async distance
        edges.add(edge);
      }

      // Add Route
      routes.add(Route(name: routeName, nodes: nodes, edges: edges));
    }
  }

  return routes;
}
*/



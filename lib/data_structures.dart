class Node {
  String name;
  double latitude;
  double longitude;
  Node? next;

  Node({required this.name, required this.latitude, required this.longitude});
}

class Edge {
  Node from;
  Node to;
  double? distance;

  Edge({required this.from, required this.to, this.distance});
}

class Route {
  Node? head;
  String name;
  int routeID;

  Route({required this.name, required this.routeID});

  void display() {
    if (head == null) {
      print("The list is empty.");
      return;
    }
    Node? current = head;
    do {
      print(
          "Node: ${current!.name}, Latitude: ${current.latitude}, Longitude: ${current.longitude}");
      current = current.next;
    } while (current != head); // Circular condition
  }
}

Route createCLL(int id, String routeName, List<String> nodeNames,
    List<double> latitudes, List<double> longitudes) {
  if (nodeNames.length != latitudes.length ||
      nodeNames.length != longitudes.length) {
    throw Exception(
        "The lengths of nodeNames, latitudes, and longitudes must be the same.");
  }

  Route route = Route(name: routeName, routeID: id);
  Node? previousNode;
  for (int i = 0; i < nodeNames.length; i++) {
    Node newNode = Node(
      name: nodeNames[i],
      latitude: latitudes[i],
      longitude: longitudes[i],
    );

    if (route.head == null) {
      route.head = newNode;
    } else {
      previousNode!.next = newNode;
    }
    previousNode = newNode;
  }

  if (previousNode != null) {
    previousNode.next = route.head; // Make the list circular
  }

  return route;
}

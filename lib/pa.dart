import 'dart:collection';

class Node {
  final String name; // Optional: For easy identification
  final Set<Bus> buses = {};

  Node(this.name);
}

class Bus {
  final String name; // Name of the bus for messages
  final List<Node> nodes = [];

  Bus(this.name);
}

List<dynamic> findPath(Node start, Node end) {
  // Map to track the parent node for reconstructing the path
  final Map<Node, Node?> parentMap = {};
  // Map to track the bus used to reach a node
  final Map<Node, Bus?> busMap = {};
  // Queue for BFS
  final Queue<Node> queue = Queue();
  // Visited set to avoid revisiting nodes
  final Set<Node> visited = {};

  // Initialize BFS
  queue.add(start);
  visited.add(start);
  parentMap[start] = null;
  busMap[start] = null;

  // Perform BFS
  while (queue.isNotEmpty) {
    final current = queue.removeFirst();

    // Check if we have reached the destination
    if (current == end) {
      List<dynamic> path = _reconstructPathWithBus(parentMap, busMap, end);
      bubbleUp(path);
      return path;
    }

    // Explore all nodes reachable via the buses
    for (var bus in current.buses) {
      for (var neighbor in bus.nodes) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
          parentMap[neighbor] = current;
          busMap[neighbor] = bus;
        }
      }
    }
  }

  // Return empty list if no path is found
  return [];
}

void bubbleUp(List<dynamic> path) {
  for (int i = 0; i < path.length - 1; i++) {
    if (path[i].runtimeType != path[i + 1].runtimeType) {
      dynamic temp = path[i];
      path[i] = path[i + 1];
      path[i + 1] = temp;
    }
  }
}

List<dynamic> _reconstructPathWithBus(
    Map<Node, Node?> parentMap, Map<Node, Bus?> busMap, Node end) {
  final path = <dynamic>[];
  Node? current = end;
  Bus? lastBus;

  while (current != null) {
    final bus = busMap[current];

    // Add a message for the bus if it's different from the last bus
    if (bus != null && bus != lastBus) {
      path.insert(0, "Get on ${bus.name}");
      lastBus = bus;
    }

    // Add the current node
    path.insert(0, current);

    // Move to the parent node
    current = parentMap[current];
  }

  return path;
}

void main() {
  // Example usage:
  final nodeA = Node('A');
  final nodeB = Node('B');
  final nodeC = Node('C');
  final nodeD = Node('D');

  final bus1 = Bus('Bus1');
  final bus2 = Bus('Bus2');

  bus1.nodes.addAll([nodeA, nodeB]);
  bus2.nodes.addAll([nodeB, nodeC, nodeD]);

  nodeA.buses.add(bus1);
  nodeB.buses.addAll([bus1, bus2]);
  nodeC.buses.add(bus2);
  nodeD.buses.add(bus2);

  final path = findPath(nodeA, nodeD);

  if (path.isEmpty) {
    print('No path found.');
  } else {
    print('Path found:');
    for (var step in path) {
      if (step is Node) {
        print(step.name);
      } else if (step is String) {
        print(step);
      }
    }
  }
}

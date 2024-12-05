import 'data_structures.dart';
import 'dart:collection';

List<List<Node>> findPaths(List<Route> routes, Node startNode, Node endNode) {
  // Adjacency list to store graph representation
  Map<Node, List<Node>> graph = {};

  // Build the graph from the routes
  for (var route in routes) {
    Node? current = route.head;
    if (current == null) continue;

    do {
      if (!graph.containsKey(current)) {
        graph[current] = [];
      }

      // Add edge to the next node in the route
      if (current.next != null) {
        graph[current]!.add(current.next!);
      }
      current = current.next;
    } while (current != route.head);
  }

  // Function to perform BFS and find all paths
  List<List<Node>> bfs(Node start, Node end) {
    List<List<Node>> result = [];
    Queue<List<Node>> queue = Queue();
    queue.add([start]);

    while (queue.isNotEmpty) {
      List<Node> path = queue.removeFirst();
      Node currentNode = path.last;

      if (currentNode == end) {
        result.add(path);
        continue;
      }

      for (Node neighbor in graph[currentNode] ?? []) {
        if (!path.contains(neighbor)) {
          List<Node> newPath = List.from(path);
          newPath.add(neighbor);
          queue.add(newPath);
        }
      }
    }

    return result;
  }

  // Get all paths from start to end
  return bfs(startNode, endNode);
}

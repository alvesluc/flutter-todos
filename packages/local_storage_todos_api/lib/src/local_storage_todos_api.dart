import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todos_api/todos_api.dart';

/// {@template local_storage_todos_api}
/// A Flutter implementation of the TodosApi that uses local storage.
/// {@endtemplate}
class LocalStorageTodosApi extends TodosApi {
  /// {@macro local_storage_todos_api}
  LocalStorageTodosApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;

  final _todoStreamController = BehaviorSubject<List<Todo>>.seeded(const []);

  /// The key used for storing the todos locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const todosCollectionKey = '__todo_collection_key__';

  String? _getValue(String key) {
    return _plugin.getString(key);
  }

  Future<void> _setValue(String key, String value) {
    return _plugin.setString(key, value);
  }

  void _init() {
    final todosJson = _getValue(todosCollectionKey);
    if (todosJson != null) {
      // TODO: Improve readability.
      final todos = List<Map<dynamic, dynamic>>.from(
        jsonDecode(todosJson) as List,
      )
          .map((jsonMap) => Todo.fromJson(Map<String, dynamic>.from(jsonMap)))
          .toList();
      _todoStreamController.add(todos);
    } else {
      _todoStreamController.add(const []);
    }
  }

  @override
  Future<int> clearCompleted() async {
    final todos = [..._todoStreamController.value];
    final completedTodosAmount = todos.where((e) => e.isCompleted).length;
    todos.removeWhere((e) => e.isCompleted);
    _todoStreamController.add(todos);
    await _setValue(todosCollectionKey, jsonEncode(todos));
    return completedTodosAmount;
  }

  @override
  Future<int> completeAll({required bool isCompleted}) async {
    final todos = [..._todoStreamController.value];
    final changedTodos = todos.where((e) => e.isCompleted != isCompleted);
    final changedTodosAmount = changedTodos.length;
    final newTodos = <Todo>[];
    for (final todo in todos) {
      newTodos.add(todo.copyWith(isCompleted: isCompleted));
    }
    _todoStreamController.add(newTodos);
    await _setValue(todosCollectionKey, jsonEncode(newTodos));
    return changedTodosAmount;
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((e) => e.id == id);
    if (todoIndex == -1) {
      throw TodoNotFoundException();
    } else {
      todos.removeAt(todoIndex);
      _todoStreamController.add(todos);
      return _setValue(todosCollectionKey, jsonEncode(todos));
    }
  }

  @override
  Stream<List<Todo>> getTodos() {
    return _todoStreamController.asBroadcastStream();
  }

  @override
  Future<void> saveTodo(Todo todo) async {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((e) => e.id == todo.id);
    if (todoIndex >= 0) {
      todos[todoIndex] = todo;
    } else {
      todos.add(todo);
    }

    _todoStreamController.add(todos);
    return _setValue(todosCollectionKey, jsonEncode(todo));
  }
}

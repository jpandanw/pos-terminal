import 'package:result_dart/result_dart.dart';

abstract class Repository<T extends Object> {
  AsyncResult<List<T>> get();
  AsyncResult<T> getById(String id);
  AsyncResult update(T object);
  AsyncResult delete(String id);
}

/// Simple wrapper for operations where failure is expected and must be
/// shown to the user rather than thrown as an exception up through the
/// widget tree (e.g. health sync, notification scheduling — see §32).
///
/// Kept intentionally minimal: no `map`/`fold` combinator chain, since the
/// app only ever needs to branch once on success/failure at the call site.
sealed class AppResult<T> {
  const AppResult();

  const factory AppResult.success(T value) = AppSuccess<T>;
  const factory AppResult.failure(String message) = AppFailure<T>;
}

final class AppSuccess<T> extends AppResult<T> {
  final T value;
  const AppSuccess(this.value);
}

final class AppFailure<T> extends AppResult<T> {
  final String message;
  const AppFailure(this.message);
}

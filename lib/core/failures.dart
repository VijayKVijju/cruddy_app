sealed class Failure {
  final String message;
  const Failure(this.message);
}
final class DecodeFailure extends Failure {
  const DecodeFailure(String msg) : super(msg);
}

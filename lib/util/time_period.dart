import 'package:aurum/util/extensions.dart';

class TimePeriod {
  final DateTime start, end;

  const TimePeriod.between(this.start, this.end);

  TimePeriod.fromNow({Duration? duration, DateTime? untilTime})
      : this._from(timeNow: DateTime.now(), duration: duration, time: untilTime);

  TimePeriod.fromToday({Duration? duration, DateTime? untilTime})
      : this._from(timeNow: DateTime.now().date, duration: duration, time: untilTime);

  TimePeriod.untilNow({Duration? duration, DateTime? fromTime})
      : this._until(timeNow: DateTime.now(), duration: duration, time: fromTime);

  TimePeriod.untilToday({Duration? duration, DateTime? fromTime})
      : this._until(timeNow: DateTime.now().nextDay.date, duration: duration, time: fromTime);

  TimePeriod._from({required DateTime timeNow, Duration? duration, DateTime? time})
      : assert((duration == null) != (time == null), 'Either duration or time must be provided (not both)'),
        start = timeNow,
        end = duration != null ? timeNow.add(duration) : time!;

  TimePeriod._until({required DateTime timeNow, Duration? duration, DateTime? time})
      : assert((duration == null) != (time == null), 'Either duration or time must be provided (not both)'),
        start = duration != null ? timeNow.subtract(duration) : time!,
        end = timeNow;

  Iterable<DateTime> days() sync* {
    for (var date = start; date < end; date = date.nextDay) {
      yield date;
    }
  }

  TimePeriod copyWith({DateTime? start, DateTime? end}) => TimePeriod.between(start ?? this.start, end ?? this.end);

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  bool operator ==(Object other) => other is TimePeriod && start == other.start && end == other.end;

  bool contains(DateTime date) => start <= date && date < end;
}

import 'package:aurum/util/extensions.dart';

class TimeConstraint {
  final DateTime? start, end;

  const TimeConstraint._between(this.start, this.end);

  TimeConstraint.fromNow() : this.from(timeNow: DateTime.now());

  TimeConstraint.fromToday() : this.from(timeNow: DateTime.now().date);

  TimeConstraint.untilNow() : this.until(timeNow: DateTime.now());

  TimeConstraint.untilToday() : this.until(timeNow: DateTime.now().nextDay.date);

  TimeConstraint.from({required DateTime timeNow})
      : start = timeNow,
        end = null;

  TimeConstraint.until({required DateTime timeNow})
      : start = null,
        end = timeNow;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  operator ==(Object other) => other is TimeConstraint && start == other.start && end == other.end;

  bool contains(DateTime date) => start != null ? start! <= date : date < end!;
}

class TimePeriod extends TimeConstraint {
  const TimePeriod.between(DateTime super.start, DateTime super.end) : super._between();

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
        super._between(timeNow, duration != null ? timeNow.add(duration) : time!);

  TimePeriod._until({required DateTime timeNow, Duration? duration, DateTime? time})
      : assert((duration == null) != (time == null), 'Either duration or time must be provided (not both)'),
        super._between(duration != null ? timeNow.subtract(duration) : time!, timeNow);

  Iterable<DateTime> days() sync* {
    for (var date = start!; date < super.end!; date = date.nextDay) {
      yield date;
    }
  }

  TimePeriod copyWith({DateTime? start, DateTime? end}) => TimePeriod.between(start ?? this.start!, end ?? this.end!);

  int get lengthInDays => end!.difference(start!).inDays;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  bool operator ==(Object other) => other is TimePeriod && start == other.start && end == other.end;

  @override
  bool contains(DateTime date) => start! <= date && date < end!;
}

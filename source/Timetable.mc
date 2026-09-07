import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

// One lesson period, shared across all active days.
class Period {
    var startLabel as String;
    var endLabel as String;
    var startMinutes as Number; // minutes since midnight, for "current period" lookup
    var endMinutes as Number;
    var isBreak as Boolean;

    function initialize(start as String, end as String, brk as Boolean) {
        startLabel = start;
        endLabel = end;
        isBreak = brk;
        startMinutes = Timetable.toMinutes(start);
        endMinutes = Timetable.toMinutes(end);
    }
}

// Parsed timetable: periods + which days are active + subject per (day, period).
class Timetable {
    var periods as Array<Period>;
    var activeDays as Array<Number>; // 0=Sun..6=Sat, sorted
    var lessons as Dictionary<Number, Array<String> >; // day -> subjects aligned to periods

    function initialize(p as Array<Period>, days as Array<Number>, l as Dictionary<Number, Array<String> >) {
        periods = p;
        activeDays = days;
        lessons = l;
    }

    // Splits `s` on single-character delimiter `delim` (Monkey C's String has no split()).
    static function splitStr(s as String, delim as String) as Array<String> {
        var result = [] as Array<String>;
        var start = 0;
        var idx = s.find(delim);
        while (idx != null) {
            result.add(s.substring(start, idx) as String);
            start = idx + delim.length();
            idx = s.substring(start, s.length()).find(delim);
            if (idx != null) { idx += start; }
        }
        result.add(s.substring(start, s.length()) as String);
        return result;
    }

    // Seed format: P=hh:mm-hh:mmB?,...|D=0,1,2,...|d:subj,subj,...;d:subj,...
    static function parse(seed as String) as Timetable? {
        var sections = Timetable.splitStr(seed, "|");
        var pStr = null;
        var dStr = null;
        var lStr = null;
        for (var i = 0; i < sections.size(); i++) {
            var s = sections[i] as String;
            if (s.find("P=") == 0) { pStr = s.substring(2, s.length()); }
            else if (s.find("D=") == 0) { dStr = s.substring(2, s.length()); }
            else if (s.find("L=") == 0) { lStr = s.substring(2, s.length()); }
        }
        if (pStr == null || dStr == null || lStr == null) {
            return null;
        }

        var periods = [] as Array<Period>;
        var pParts = Timetable.splitStr(pStr as String, ",");
        for (var i = 0; i < pParts.size(); i++) {
            var part = pParts[i] as String;
            var brk = false;
            if (part.length() > 0 && part.substring(part.length() - 1, part.length()).equals("B")) {
                brk = true;
                part = part.substring(0, part.length() - 1);
            }
            var range = Timetable.splitStr(part, "-");
            if (range.size() != 2) { continue; }
            periods.add(new Period(range[0] as String, range[1] as String, brk));
        }
        if (periods.size() == 0) {
            return null;
        }

        var days = [] as Array<Number>;
        var dParts = Timetable.splitStr(dStr as String, ",");
        for (var i = 0; i < dParts.size(); i++) {
            var n = (dParts[i] as String).toNumber();
            if (n != null) { days.add(n); }
        }
        if (days.size() == 0) {
            return null;
        }

        var lessons = {} as Dictionary<Number, Array<String> >;
        var lParts = Timetable.splitStr(lStr as String, ";");
        for (var i = 0; i < lParts.size(); i++) {
            var entry = lParts[i] as String;
            var colon = entry.find(":");
            if (colon == null) { continue; }
            var day = entry.substring(0, colon).toNumber();
            if (day == null) { continue; }
            var subjStr = entry.substring(colon + 1, entry.length());
            var subs = Timetable.splitStr(subjStr, ",");
            var arr = [] as Array<String>;
            for (var j = 0; j < subs.size(); j++) {
                arr.add(subs[j] as String);
            }
            lessons[day] = arr;
        }

        return new Timetable(periods, days, lessons);
    }

    static function toMinutes(hhmm as String) as Number {
        var parts = Timetable.splitStr(hhmm, ":");
        if (parts.size() != 2) { return 0; }
        var h = (parts[0] as String).toNumber();
        var m = (parts[1] as String).toNumber();
        if (h == null) { h = 0; }
        if (m == null) { m = 0; }
        return h * 60 + m;
    }

    // Subject for a given day-of-week (0=Sun..6=Sat) and period index; "" if free/break/inactive.
    function subjectAt(day as Number, periodIdx as Number) as String {
        if (periods[periodIdx].isBreak) {
            return "Break";
        }
        var arr = lessons.get(day) as Array<String>?;
        if (arr == null || periodIdx >= arr.size()) {
            return "";
        }
        return arr[periodIdx];
    }

    function isDayActive(day as Number) as Boolean {
        for (var i = 0; i < activeDays.size(); i++) {
            if (activeDays[i] == day) { return true; }
        }
        return false;
    }

    // Index of activeDays entry equal to `day`, or -1.
    function activeDayIndex(day as Number) as Number {
        for (var i = 0; i < activeDays.size(); i++) {
            if (activeDays[i] == day) { return i; }
        }
        return -1;
    }

    // Finds the period index that contains/comes at-or-after `nowMinutes` today.
    // Returns periods.size() if the school day is over.
    function currentOrNextPeriodIndex(nowMinutes as Number) as Number {
        for (var i = 0; i < periods.size(); i++) {
            if (nowMinutes < periods[i].endMinutes) {
                return i;
            }
        }
        return periods.size();
    }
}

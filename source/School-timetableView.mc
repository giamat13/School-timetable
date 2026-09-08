import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.System;

const DAY_NAMES = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] as Array<String>;

class TimetableView extends WatchUi.View {

    var timetable as Timetable;
    // Flattened list of (dayIndexInActiveDays, periodIndex) slots the user can scroll through,
    // built fresh each time we enter, starting at "today, current/next period".
    var cursor as Number = 0;

    function initialize(t as Timetable) {
        View.initialize();
        timetable = t;
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        resetToNow();
    }

    function resetToNow() as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dow = now.day_of_week - 1; // Moment API: 1=Sun..7=Sat -> 0=Sun..6=Sat
        var nowMinutes = now.hour * 60 + now.min;

        var dayIdx = timetable.activeDayIndex(dow);
        var periodIdx = 0;
        if (dayIdx >= 0) {
            periodIdx = timetable.currentOrNextPeriodIndex(nowMinutes);
            if (periodIdx >= timetable.periods.size()) {
                // Day is over: jump to first period of the next active day.
                dayIdx = (dayIdx + 1) % timetable.activeDays.size();
                periodIdx = 0;
            }
        } else {
            // Today isn't a school day: show the first period of the next active day, if any.
            dayIdx = nextActiveDayIndexAfter(dow);
            periodIdx = 0;
        }
        cursor = dayIdx * 1000 + periodIdx; // encode as (day * 1000 + period); periods.size() always < 1000
    }

    function nextActiveDayIndexAfter(dow as Number) as Number {
        if (timetable.activeDays.size() == 0) { return 0; }
        for (var offset = 1; offset <= 7; offset++) {
            var candidate = (dow + offset) % 7;
            var idx = timetable.activeDayIndex(candidate);
            if (idx >= 0) { return idx; }
        }
        return 0;
    }

    function move(delta as Number) as Void {
        var numPeriods = timetable.periods.size();
        var numDays = timetable.activeDays.size();
        if (numDays == 0 || numPeriods == 0) { return; }

        var dayIdx = cursor / 1000;
        var periodIdx = cursor % 1000;

        periodIdx += delta;
        while (periodIdx < 0) {
            dayIdx = (dayIdx - 1 + numDays) % numDays;
            periodIdx += numPeriods;
        }
        while (periodIdx >= numPeriods) {
            dayIdx = (dayIdx + 1) % numDays;
            periodIdx -= numPeriods;
        }
        cursor = dayIdx * 1000 + periodIdx;
        WatchUi.requestUpdate();
    }

    function moveDay(delta as Number) as Void {
        var numDays = timetable.activeDays.size();
        if (numDays == 0) { return; }

        var dayIdx = cursor / 1000;
        var periodIdx = cursor % 1000;

        dayIdx = (dayIdx + delta + numDays * 100) % numDays;
        cursor = dayIdx * 1000 + periodIdx;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        var dayIdx = cursor / 1000;
        var periodIdx = cursor % 1000;
        if (dayIdx >= timetable.activeDays.size() || periodIdx >= timetable.periods.size()) {
            return;
        }
        var day = timetable.activeDays[dayIdx];
        var period = timetable.periods[periodIdx];
        var subject = timetable.subjectAt(day, periodIdx);
        if (subject.equals("")) {
            subject = "Free";
        }

        var dayLabel = DAY_NAMES[day];
        if (!period.isBreak) {
            dayLabel += "  •  Period " + period.lessonNumber;
        }
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.16, Graphics.FONT_MEDIUM, dayLabel, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.30, Graphics.FONT_SMALL, period.startLabel + " - " + period.endLabel, Graphics.TEXT_JUSTIFY_CENTER);

        var subjectColor = period.isBreak ? Graphics.COLOR_ORANGE : Graphics.COLOR_WHITE;
        dc.setColor(subjectColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.5, Graphics.FONT_LARGE, subject, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var suffix = "";
        if (!System.getDeviceSettings().is24Hour) {
            suffix = hour >= 12 ? " PM" : " AM";
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var minStr = clockTime.min < 10 ? "0" + clockTime.min : clockTime.min.toString();
        var timeStr = hour.toString() + ":" + minStr + suffix;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.85, Graphics.FONT_SMALL, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {
    }

}

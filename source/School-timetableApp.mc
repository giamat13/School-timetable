import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class School_timetableApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var seed = Application.Properties.getValue("timetableSeed") as String?;
        if (seed == null || seed.equals("")) {
            return [ new NoSeedView() ];
        }
        var timetable = Timetable.parseSchedule(seed);
        if (timetable == null) {
            return [ new NoSeedView() ];
        }
        var view = new TimetableView(timetable);
        return [ view, new TimetableDelegate(view) ];
    }

}

function getApp() as School_timetableApp {
    return Application.getApp() as School_timetableApp;
}

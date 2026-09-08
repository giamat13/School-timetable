import Toybox.WatchUi;
import Toybox.Lang;

// Delegate for the widget's initial (glance) view. Garmin restricts touch
// input on a widget's *initial* view to select/tap only - swipe never
// reaches it on touch devices (confirmed by Garmin staff:
// https://forums.garmin.com/developer/connect-iq/f/discussion/258395/behaviordelegate-and-vivoactive4).
// So a tap here "enters" the widget by pushing a second view+delegate,
// which - not being the initial view - receives full swipe/back input.
class TimetableDelegate extends WatchUi.BehaviorDelegate {

    var view as TimetableView;

    function initialize(v as TimetableView) {
        BehaviorDelegate.initialize();
        view = v;
    }

    function onSelect() as Boolean {
        WatchUi.pushView(view, new TimetableScrollDelegate(view), WatchUi.SLIDE_UP);
        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            view.move(1);
            return true;
        } else if (dir == WatchUi.SWIPE_DOWN) {
            view.move(-1);
            return true;
        }
        return false;
    }

    function onNextPage() as Boolean {
        view.move(1);
        return true;
    }

    function onPreviousPage() as Boolean {
        view.move(-1);
        return true;
    }

}

// Delegate for the pushed, "entered" view: swipe up/down scrolls; back pops
// back out to the widget glance.
class TimetableScrollDelegate extends WatchUi.BehaviorDelegate {

    var view as TimetableView;

    function initialize(v as TimetableView) {
        BehaviorDelegate.initialize();
        view = v;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            view.move(1);
            return true;
        } else if (dir == WatchUi.SWIPE_DOWN) {
            view.move(-1);
            return true;
        }
        return false;
    }

    function onNextPage() as Boolean {
        view.move(1);
        return true;
    }

    function onPreviousPage() as Boolean {
        view.move(-1);
        return true;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}

import Toybox.WatchUi;
import Toybox.Lang;

class TimetableDelegate extends WatchUi.BehaviorDelegate {

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
        // Older touch devices (e.g. vivoactive 4S) can report a scroll as a
        // slightly-off-axis swipe; consume it too so it doesn't fall through
        // to the system and switch to the next widget.
        return true;
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

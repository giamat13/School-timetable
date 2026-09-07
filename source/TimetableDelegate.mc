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

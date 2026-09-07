import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Communications;
import Toybox.Application;

const SETUP_URL = "https://giamat13.github.io/School-timetable";

// Shown when no seed has been configured yet: a QR code to the web config tool,
// and a best-effort attempt to open it directly on a paired phone.
class NoSeedView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        if (Communications has :openWebPage) {
            Communications.openWebPage(SETUP_URL, {}, null);
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.drawText(cx, h * 0.12, Graphics.FONT_SMALL, "Scan to set up", Graphics.TEXT_JUSTIFY_CENTER);

        var qr = Application.loadResource(Rez.Drawables.QrCode) as BitmapResource;
        var qrSize = qr.getWidth();
        dc.drawBitmap(cx - qrSize / 2, h * 0.5 - qrSize / 2, qr);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.86, Graphics.FONT_XTINY, SETUP_URL, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {
    }

}

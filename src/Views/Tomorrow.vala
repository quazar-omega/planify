public class Views.Tomorrow : Gtk.EventBox {
    public Tomorrow () {
        Object (
            expand: true
        );
    }

    construct {
        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);

        var tomorrow_icon = new Gtk.Image.from_icon_name ("planner-tomorrow", Gtk.IconSize.DND);

        var tomorrow_label = new Gtk.Label ("<b>%s</b>".printf (Application.utils.TOMORROW_STRING));
        tomorrow_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        tomorrow_label.use_markup = true;

        var settings_button = new Gtk.ToggleButton ();
        settings_button.add (new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.BUTTON));
        settings_button.tooltip_text = _("Settings");
        settings_button.valign = Gtk.Align.CENTER;
        settings_button.halign = Gtk.Align.CENTER;
        settings_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        top_box.hexpand = true;
        top_box.margin = 24;

        top_box.pack_start (tomorrow_icon, false, false, 0);
        top_box.pack_start (tomorrow_label, false, false, 12);
        top_box.pack_end (settings_button, false, false, 0);

        var main_grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;

        main_grid.add (top_box);

        add (main_grid);
    }
}

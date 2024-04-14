/*
* Copyright © 2023 Alain M. (https://github.com/alainm23/planify)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class Widgets.ReminderPicker._ReminderPicker : Gtk.Popover {  
    private Layouts.HeaderItem reminders_view;
    private Widgets.Calendar.Calendar calendar;
    private Widgets.DateTimePicker.TimePicker time_picker;
    private Gtk.Stack main_stack;
    private Widgets.LoadingButton submit_button;

    private Gee.HashMap<string, Widgets.ReminderPicker.ReminderRow> reminders_map;

    public signal void reminder_added (Objects.Reminder reminder);

    public _ReminderPicker () {
        Object (
            position: Gtk.PositionType.BOTTOM,
            width_request: 250
        );
    }

    construct {
        reminders_map = new Gee.HashMap<string, Widgets.ReminderPicker.ReminderRow> ();

        reminders_view = new Layouts.HeaderItem (_("Reminders")) {
            margin_bottom = 9,
            margin_top = 12
        };
        reminders_view.reveal_child = true;
        reminders_view.placeholder_message = _("Your list of reminders will show up here. Add one by clicking the '+' button.");

        var add_button = new Gtk.Button.from_icon_name ("plus-large-symbolic") {
            valign = Gtk.Align.CENTER,
            can_focus = false,
            css_classes = { Granite.STYLE_CLASS_FLAT, "header-item-button" }
        };

        reminders_view.add_widget_end (add_button);

        var scrolled_window = new Gtk.ScrolledWindow () {
            hexpand = true,
            vexpand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vscrollbar_policy = Gtk.PolicyType.NEVER,
            child = reminders_view
        };

        main_stack = new Gtk.Stack () {
            vexpand = true,
            hexpand = true,
            vhomogeneous = false,
            hhomogeneous = false,
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };
        main_stack.add_named (scrolled_window, "listbox");
        main_stack.add_named (get_picker (), "picker");

        child = main_stack;

        add_button.clicked.connect (() => {
            time_picker.has_time = true;
            time_picker.no_time_visible = false;
            time_picker.time = new GLib.DateTime.now_local ().add_hours (1);
            main_stack.visible_child_name = "picker";
        });

        closed.connect (() => {
            main_stack.visible_child_name = "listbox";
            submit_button.is_loading = false;
        });
    }

    private void insert_reminder () {
        var reminder = new Objects.Reminder ();
        reminder.due.date = Util.get_default ().get_todoist_datetime_format (get_datetime_picker ());

        reminder_added (reminder);
        main_stack.visible_child_name = "listbox";
        submit_button.is_loading = false;
    }

    private GLib.DateTime get_datetime_picker () {
        return new DateTime.local (
            calendar.date.get_year (),
            calendar.date.get_month (),
            calendar.date.get_day_of_month (),
            time_picker.time.get_hour (),
            time_picker.time.get_minute (),
            0
        );
    }

    private Gtk.Widget get_picker () {
        calendar = new Widgets.Calendar.Calendar (true) {
            vexpand = true,
            hexpand = true
        };

        var calendar_grid = new Adw.Bin () {
            child = calendar,
            css_classes = { "card" }
        };

        var time_icon = new Gtk.Image.from_icon_name ("alarm-symbolic") {
            margin_start = 9
        };

        var time_label = new Gtk.Label (_("Time")) {
            margin_start = 6,
            css_classes = { "font-weight-500" }
        };

        time_picker = new Widgets.DateTimePicker.TimePicker () {
            hexpand = true,
            halign = Gtk.Align.END
        };

        var time_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            hexpand = true,
            margin_top = 6,
            css_classes = { "card" }
        };

        time_box.append (time_icon);
        time_box.append (time_label);
        time_box.append (time_picker);

        submit_button = new Widgets.LoadingButton (LoadingButtonType.LABEL, _("Add Reminder")) {
            margin_top = 12,
            margin_start = 3,
            margin_end = 3,
            margin_bottom = 6,
            css_classes = { Granite.STYLE_CLASS_SUGGESTED_ACTION }
        };

        var main_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_grid.append (calendar_grid);
        main_grid.append (time_box);
        main_grid.append (submit_button);

        submit_button.clicked.connect (insert_reminder);

        return main_grid;
    }

    public void set_reminders (Gee.ArrayList<Objects.Reminder> reminders) {
        clear ();
        
        foreach (Objects.Reminder reminder in reminders) {
            add_reminder (reminder);
        }
    }

    public void clear () {
        reminders_view.clear ();
        reminders_map.clear ();
    }

    public void add_reminder (Objects.Reminder reminder) {
        if (!reminders_map.has_key (reminder.id)) {
            reminders_map [reminder.id] = new Widgets.ReminderPicker.ReminderRow (reminder);
            reminders_view.add_child (reminders_map[reminder.id_string]);
        }
    }

    public void delete_reminder (Objects.Reminder reminder) {
        if (reminders_map.has_key (reminder.id_string)) {
            reminders_map[reminder.id_string].hide_destroy ();
            reminders_map.unset (reminder.id_string);
        }
    }
}

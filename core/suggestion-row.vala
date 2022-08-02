/*
 Copyright (C) 2018 Christian Dywan <christian@twotoats.de>

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 See the file COPYING for the full license text.
*/

namespace Midori {
    [GtkTemplate (ui = "/ui/suggestion-row.ui")]
    public class SuggestionRow : Gtk.ListBoxRow {
        public DatabaseItem item { get; protected set; }
        public string? location { get; set; }
        public Regex? regex { get; set; }
        public string? key { get; set; }
        [GtkChild]
        unowned Gtk.Box box;
        [GtkChild]
        unowned Favicon icon;
        [GtkChild]
        unowned Gtk.Label title;
        [GtkChild]
        unowned Gtk.Label uri;
        [GtkChild]
        unowned Gtk.Button delete;
        public SuggestionRow (DatabaseItem item) {
            Object (item: item);
            if (item is SuggestionItem) {
                box.set_child_packing (title, true, true, 0, Gtk.PackType.END);
                title.use_underline = true;
                notify["location"].connect ((pspec) => {
                    if (location != null) {
                        item.uri = location;
                        icon.icon_name = "go-jump-symbolic";
                        uri.label = Markup.escape_text (location);
                        title.label = "";
                    }
                });
                notify["key"].connect ((pspec) => {
                    if (location == null) {
                        var suggestion = (SuggestionItem)item;
                        item.uri = CoreSettings.get_default ().uri_for_search (key, suggestion.search);
                        icon.icon_name = "edit-find-symbolic";
                        uri.label = Markup.escape_text (key);
                        title.label = item.title;
                    }
                });
            // Double-check type for the sake of plugins
            } else if (item is DatabaseItem) {
                icon.uri = item.uri;
                title.label = item.title != null ? render (item.title) : "";
                uri.label = render (strip_uri_prefix (item.uri));
                notify["key"].connect ((pspec) => {
                    title.label = item.title != null ? render (item.title) : "";
                    uri.label = render (strip_uri_prefix (item.uri));
                });
            }
            // Delete button to remove suggestions from history
            this.delete.visible = item.database != null && !item.database.readonly;
            this.delete.clicked.connect (() => { item.delete.begin (); });
        }

        string render (string text) {
            if (key != null && key[0] != '\0') {
                int index = text.down ().index_of (key.down ());
                if (index > -1) {
                    return Markup.printf_escaped ("%s<b>%s</b>%s",
                        text.substring (0, index), key, text.substring (index + key.length));
                }
            }
            return Markup.escape_text (text);
        }

        string? strip_uri_prefix (string uri) {
            bool is_http = uri.has_prefix ("http://") || uri.has_prefix ("https://");
            if (is_http || uri.has_prefix ("file://")) {
                string stripped_uri = uri.split ("://")[1];
                if (is_http && stripped_uri.has_prefix ("www."))
                    return stripped_uri.substring (4, -1);
                return stripped_uri;
            }
            return uri;
        }
    }
}

void user_command(FouineShell fouineInstance, string user) {
    var session = new Soup.Session();
    var message = new Soup.Message("GET", @"https://api.intra.42.fr/v2/users/$(user)");

    message.request_headers.append("Authorization", @"Bearer $(fouineInstance.token)");

    try {
        GLib.Bytes response = session.send_and_read (message, null);
        
        string json_string = (string)response.get_data();

        var parser = new Json.Parser();
        parser.load_from_data(json_string, -1);

        var user_object = parser.get_root().get_object();

        string login = user_object.get_string_member ("login");
        string firstname = user_object.get_string_member ("first_name");
        string lastname = user_object.get_string_member ("last_name");
        string email = user_object.get_string_member ("email");
    
        print (@"$(login): $(firstname) $(lastname)\n$(email)\n");
    } catch (GLib.Error e) {
        printerr (@"Request failed: $(e.message)\n");
    }
}

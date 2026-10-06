[Compact (opaque = true)]
class FouineShell {
	private int _status;
	public int status {
		get { return _status; }
		set { _status = value; }
	}

	private string _env_file = Path.build_filename (Environment.get_home_dir (), ".fouine.env");
	public string env_file { get { return _env_file; }}

	private string _uid;
	public string uid { get { return _uid; } set { _uid = value; } }

	private string _secret;
	public string secret { get { return _secret; } set { _secret = value; } }

	private string _token;
	public string token { get { return _token; } set { _token = value; } }

	private string[,] _commandList = {
			{"exit", "Quit FouineShell."},
			{"help", "Show help menu (this page)."},
			{"user <login>", "Show some datas about a user."}
	};
	public string[,] commandList {
		get { return _commandList; }
	}

	public FouineShell() {
		print("Welcome! Here is \x1b[1;35mFouineShell\x1b[0m.\n");
	}

	~FouineShell() {
		print("Goodbye.\n");
	}

	public int init_token() {
		var session = new Soup.Session();
		var message = new Soup.Message("POST", "https://api.intra.42.fr/oauth/token");

		string payload = @"grant_type=client_credentials&client_id=$(this.uid)&client_secret=$(this.secret)";

		var bytes = new GLib.Bytes(payload.data);

		message.set_request_body_from_bytes ("application/x-www-form-urlencoded", bytes);

		try {
			GLib.Bytes response = session.send_and_read (message, null);
			
			string status_mess = (message.status_code == 200 ? @"\x1b[1;32m$(message.status_code) $(message.reason_phrase)\x1b[0m" : @"$(message.status_code) $(message.reason_phrase)");
			print(@"Status: $(status_mess)\n");
			//  print(@"Response:\n$(response.get_data())\n");

			string json_string = (string)response.get_data();

			var parser = new Json.Parser();
			parser.load_from_data(json_string, -1);

			Json.Node root = parser.get_root();
			Json.Object root_obj = root.get_object();

			if (root_obj.has_member ("access_token")) {
				this.token = root_obj.get_string_member ("access_token");
				print ("Access Token: \x1b[1;32mOK\x1b[0m\n");
			} else {
				printerr ("Error: Access Token not found.\n");
				print(@"$(json_string)\n");
			}
		} catch (GLib.Error e) {
			printerr (@"Request failed: $(e.message)\n");
		}
		if (this.token == null)
			return 1;
		return 0;
	}
}

int start_prep(FouineShell fouineInstance) {
	if (FileUtils.test(fouineInstance.env_file, FileTest.EXISTS))
		print(@"$(fouineInstance.env_file) found!\n");
	else {
		try {
			FileUtils.set_contents (fouineInstance.env_file, "APP_UID=\nAPP_SECRET=\n");
			print(@"$(fouineInstance.env_file) created successfully!\n");
		} catch (FileError e) {
			printerr(@"Error: $(e.message)\n");
			return 1;
		}
	}

	string? env_content = null;

	try {
		FileUtils.get_contents(fouineInstance.env_file, out env_content);
	} catch (FileError e) {
		printerr(@"Error: $(e.message)\n");
		return 1;
	}
	
	string[]? env_tab = env_content.split("\n");
	foreach (string env_item in env_tab) {
		string[]? env_elem = env_item.split("=");
		if (env_elem[0] == "APP_UID")
			fouineInstance.uid = env_elem[1];
		if (env_elem[0] == "APP_SECRET")
			fouineInstance.secret = env_elem[1];		
	}

	return fouineInstance.init_token();;
}

string? input(string prompt_text) {
    stdout.printf("%s", prompt_text);
    stdout.flush();
    return stdin.read_line ();
}

int main(string[] args) {
	if (args.length > 1) {
		print("Error: args not handled now.\n");
		return 1;
	}

	FouineShell fouineInstance = new FouineShell();

	fouineInstance.status = start_prep(fouineInstance);

	while (fouineInstance.status == 0) {
		string? command = input("\x1b[35mFouineShell \x1b[1m→\x1b[0m ");

		string[] command_tab = command.split(" ");

		if (command == null || command == "exit")
			fouineInstance.status -= 1;
		if (command == "help")
			help_command(fouineInstance);
		if (command_tab[0] == "user" && command_tab.length == 2)
			user_command(fouineInstance, command_tab[1]);
	}

	if (fouineInstance.status == -1)
		fouineInstance.status = 0;

	return fouineInstance.status;
}

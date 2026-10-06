void help_command(FouineShell fouineInstance) {
	int col1w = 15;
	int col2w = 30;
	for (int i = 0; i < fouineInstance.commandList.length[0]; i++)
		stdout.printf("%-*s | %-*s\n", col1w, fouineInstance.commandList[i, 0], col2w, fouineInstance.commandList[i, 1]);
}

class_name QuickStartCommand extends ConsoleCommand

const message = """
[color=yellow] - Quick Start - [/color]
Enter "make my_game" to make a new project.
Enter "open my_game" to open it.

Use CTRL+Q and CTRL+E to navigate between the Console, Spriter, Mapper etc.
Use CTRL+S to save, CTRL+R to run.

In the Coder window, use CTRL+Tab or CTRL+Space to toggle the scripts list.

To browse & play games, enter "browse".
"""

func run(args:Array = []):
	ES.console.write(message)
	return OK

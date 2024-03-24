extends Object
class_name Log

static func error(text: String):
	printerr(text)
	Console.printLine("[color=red]"+text+"[/color]")

static func printerr(text: String):
	error(text)

static func warning(text: String):
	print(text)
	Console.printLine("[color=yellow]"+text+"[/color]")

static func print(text: String):
	print(text)
	Console.printLine(text)

static func info(text: String):
	print(text)


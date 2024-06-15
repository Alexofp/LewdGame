extends Object
class_name Util

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
static func remove_all_signals(node):
	var signals = node.get_signal_list();
	for cur_signal in signals:
		var conns = node.get_signal_connection_list(cur_signal.name);
		for cur_conn in conns:
			node.disconnect(cur_conn.signal, cur_conn.target, cur_conn.method)

static func maxi(value1: int, value2: int) -> int:
	if(value1 > value2):
		return value1
	return value2

static func mini(value1: int, value2: int) -> int:
	if(value1 > value2):
		return value2
	return value1

# input ["a", "a", "b", "c", "b", "a"]
# output ["a", "b", "c"]
static func uniqueElements(arr: Array):
	var saw = {}
	var result = []
	for element in arr:
		if(!saw.has(element)):
			saw[element] = true
			result.append(element)
	return result

# input ["a", "b", "c"]
# output "a, b and c"
static func humanReadableList(arr: Array, andConnector: String = "and", commaConnector: String = ","):
	var arrSize = arr.size()
	if(arrSize == 0):
		return ""
	if(arrSize == 1):
		return arr[0]
	if(arrSize == 2):
		return arr[0] + " "+andConnector+" " + arr[1]
	
	var res = ""
	for i in range(arrSize):
		if(i == (arrSize - 1)):
			res += " "+andConnector+" "
		
		res += arr[i]
		
		if(i <= (arrSize - 3)):
			res += commaConnector + " "
	return res

# Util.multipleOrSingularEnding(1, "apple") = apple
# Util.multipleOrSingularEnding(2, "apple") = apples
static func multipleOrSingularEnding(value, word, wordMultiple = null):
	if(value == 1):
		return word
	if(wordMultiple == null):
		return word+"s"
	return wordMultiple

static func getFilesInFolder(folder):
	var result = []
	var dir = Directory.new()
	if dir.open(folder) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				var full_path = folder.plus_file(file_name)
				result.append(full_path)
			file_name = dir.get_next()
	else:
		Log.printerr("An error occurred when trying to access the path "+folder)
	return result

# https://godotengine.org/qa/20058/elegant-way-to-create-string-from-array-items
static func join(arr: Array, separator: String = "") -> String:
	var output = ""
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output

static func joinWithBorders(arr: Array, separator: String = "", border: String = "\"") -> String:
	var output = ""
	for s in arr:
		output += border + str(s) + border + separator
	output = output.left( output.length() - separator.length() )
	return output

static func joinWithDifferentBorders(arr: Array, separator: String = "", leftborder: String = "\"", rightborder: String = "\"") -> String:
	var output = ""
	for s in arr:
		output += leftborder + str(s) + rightborder + separator
	output = output.left( output.length() - separator.length() )
	return output

# input 12345
# output "3h 25m 45s"
static func getTimeStringHumanReadable(t):
	var _seconds = floor(fmod(t, 60.0))
	var _minutes = floor(fmod(t/60.0, 60.0))
	var _hours = floor(fmod(t/3600.0, 24.0))
	var _days = floor(t/(3600.0*24.0))
	
	var result = ""
	if(_days > 0):
		result += str(_days)+" days "
	if(_hours > 0):
		result += str(_hours)+"h "
	if(_minutes > 0):
		result += str(_minutes)+"m "
	if(_seconds > 0):
		result += str(_seconds)+"s "
	return result.trim_suffix(" ")

# input 12345
# output "03:25:45"
static func getTimeStringHHMMSS(t):
	var _seconds = floor(fmod(t, 60.0))
	var _minutes = floor(fmod(t/60.0, 60.0))
	var _hours = floor(t/3600.0)
	
	var time = "%02d:%02d:%02d" % [_hours, _minutes, _seconds]
	
	return time
	
# input 12345
# output "03:25"
static func getTimeStringHHMM(t):
	var _seconds = floor(fmod(t, 60.0))
	var _minutes = floor(fmod(t/60.0, 60.0))
	var _hours = floor(t/3600.0)
	
	var time = "%02d:%02d" % [_hours, _minutes]
	
	return time

static func ISO8601DateToDatetime(t):
	var tsplit = t.split("T")
	if(tsplit.size() < 2):
		return null
	
	var date = tsplit[0].split("-")
	var time = tsplit[1].trim_suffix("Z").split(":")

	if(date.size() < 3 || time.size() < 3):
		return null

	var dict = {
		year = date[0],
		month = date[1],
		day = date[2],
		hour = time[0],
		minute = time[1],
		second = time[2],
	}
	var timeUnix = OS.get_unix_time_from_datetime(dict)
	return OS.get_datetime_from_unix_time(timeUnix)

static func roundF(number: float, digitsAmount: int = 0):
	var mult = 1.0
	for _i in range(digitsAmount):
		mult *= 10.0
	
	return round(number*mult)/mult

static func moveNumberTowards(origNumber, targetNumber, speed):
	var delta = targetNumber - origNumber
	if(delta > speed):
		delta = speed
	if(delta < -speed):
		delta = -speed
	
	return origNumber + delta

static func getSpeciesName(species: Array):
	if(species.size() == 0):
		return "Unknown species"
	
	if(species.size() == 1):
		var specie = GlobalRegistry.getSpecies(species[0])
		return specie.getVisibleName()
	
	var names = []
	for specieID in species:
		var specie = GlobalRegistry.getSpecies(specieID)
		names.append(specie.getVisibleName())
	
	return join(names, "-") + " hybrid"

static func numberToPercentString(value: float):
	if(value < 0):
		return str(value*100)+"%"
	if(value > 0):
		return "+"+str(value*100)+"%"
	return "0%"

static func limitedPercent(value: float):
	if value > 1:
		value = 1
	return str(roundF(value*100.0, 1))

# https://godotengine.org/qa/19077/how-to-get-the-date-as-per-rfc-1123-date-format-in-game
static func datetimeToRFC113(time):
	var nameweekday= ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var namemonth= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var dayofweek = time["weekday"]   # from 0 to 6 --> Sunday to Saturday
	var day = time["day"]                         #   1-31
	var month= time["month"]               #   1-12
	var year= time["year"]             
	var hour= time["hour"]                     #   0-23
	var minute= time["minute"]             #   0-59
	var second= time["second"]             #   0-59

	var dateRFC1123 = str(nameweekday[dayofweek]) + ", " + str("%02d" % [day]) + " " + str(namemonth[month-1]) + " " + str(year) + " " + str("%02d" % [hour]) + ":" + str("%02d" % [minute]) + ":" + str("%02d" % [second]) + " GMT"
	return dateRFC1123

static func dateToString(time):
	var namemonth= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var day = time["day"]                         #   1-31
	var month= time["month"]               #   1-12
	var year= time["year"]             

	var dateStr = str("%02d" % [day]) + " of " + str(namemonth[month-1]) + " " + str(year)
	return dateStr

static func stripBadFilenameCharacters(path: String) -> String:
	var escapeCharacters = ':/\\?*"|%<>'
	for ch in escapeCharacters:
		path = path.replace(ch, "")
	return path

static func sayMale(text):
	return "[color=#3E84E0]\""+text+"\"[/color]"
	
static func sayFemale(text):
	return "[color=#FF837A]\""+text+"\"[/color]"

static func sayAndro(text):
	return "[color=#BA82FF]\""+text+"\"[/color]"
	
static func sayOther(text):
	return "[color=#77D86C]\""+text+"\"[/color]"

static func sayPlayer(text):
	if(GM.pc == null):
		return sayFemale(text)
	
	return GM.pc.formatSay(text)

static func sayChar(charID, text):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.formatSay(text)

static func heShe(charID):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.heShe()

static func hisHer(charID):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.hisHer()
	
static func himHer(charID):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.himHer()
	
static func isAre(charID):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.isAre()
	
static func hasHave(charID):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.hasHave()
	
static func himselfHerself(charID):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.himselfHerself()

static func verbS(charID, verbWithNoS, verbWithS = null):
	var character = GlobalRegistry.getCharacter(charID)
	
	return character.verbS(verbWithNoS, verbWithS)

static func muffledSpeech(text: String, strenght: int = 1):
	var newtext = ""
	var ignore = false
	
	for ch in text:
		if(ch == "{"):
			ignore = true
			newtext += ch
			continue
		if(ignore):
			if(ch == "}"):
				ignore = false
			
			newtext += ch
			continue
		
		var isCapital = false
		var oldch = ch
		if(ch == ch.to_upper()):
			isCapital = true
		var chlower = ch.to_lower()
		
		if(strenght == 1):
			if(chlower == "l"):
				ch = "w"
			if(chlower == "r"):
				ch = "w"
			if(chlower == "s"):
				ch = "f"
			if(chlower == "t"):
				ch = "g"
		if(strenght == 2):
			if(chlower in "abjsvz"):
				ch = "r"
			if(chlower in "dklw"):
				ch = "f"
			if(chlower in "gx"):
				ch = "n"
			if(chlower in "himu"):
				ch = "d"
			if(chlower in "q"):
				ch = "m"
		if(strenght == 3):
			if(oldch in "BDKTV"):
				ch = "Mph"
			if(oldch in "bdktv"):
				ch = "m"
			if(oldch in "DJLQR"):
				ch = "M"
			if(oldch in "djlqr"):
				ch = "ph"
			if(oldch in "S"):
				ch = "H"
			if(oldch in "s"):
				ch = "m"
			if(oldch in "C"):
				ch = "Mf"
			if(oldch in "c"):
				ch = "m"
			if(oldch in "AEIOU"):
				ch = "Mph"
			if(oldch in "aeiou"):
				ch = "m"
			if(oldch in "CVNY"):
				ch = "Mh"
			if(oldch in "cvny"):
				ch = "ph"
			if(oldch in "WYZX"):
				ch = "Mf"
			if(oldch in "wyzx"):
				ch = "f"
				
		if(oldch != ch && isCapital):
			ch = ch.capitalize()

		if(RNG.chance(50)):
			newtext += ch
		else:
			newtext += oldch
		
	return newtext

static func capitalizeFirstLetter(string:String):
	if(string.length() == 0):
		return string
	return string[0].to_upper() + string.substr(1,-1)

static func variantTypeToString(type):
	if(type == TYPE_NIL):
		return "TYPE_NIL"
	if(type == TYPE_BOOL):
		return "TYPE_BOOL"
	if(type == TYPE_INT):
		return "TYPE_INT"
	if(type == TYPE_REAL):
		return "TYPE_REAL"
	if(type == TYPE_STRING):
		return "TYPE_STRING"
	if(type == TYPE_VECTOR2):
		return "TYPE_VECTOR2"
	if(type == TYPE_RECT2):
		return "TYPE_RECT2"
	if(type == TYPE_VECTOR3):
		return "TYPE_VECTOR3"
	if(type == TYPE_TRANSFORM2D):
		return "TYPE_TRANSFORM2D"
	if(type == TYPE_PLANE):
		return "TYPE_PLANE"
	if(type == TYPE_QUAT):
		return "TYPE_QUAT"
	if(type == TYPE_AABB):
		return "TYPE_AABB"
	if(type == TYPE_BASIS):
		return "TYPE_BASIS"
	if(type == TYPE_TRANSFORM):
		return "TYPE_TRANSFORM"
	if(type == TYPE_COLOR):
		return "TYPE_COLOR"
	if(type == TYPE_NODE_PATH):
		return "TYPE_NODE_PATH"
	if(type == TYPE_RID):
		return "TYPE_RID"
	if(type == TYPE_OBJECT):
		return "TYPE_OBJECT"
	if(type == TYPE_DICTIONARY):
		return "TYPE_DICTIONARY"
	if(type == TYPE_ARRAY):
		return "TYPE_ARRAY"
	if(type == TYPE_RAW_ARRAY):
		return "TYPE_RAW_ARRAY"
	if(type == TYPE_INT_ARRAY):
		return "TYPE_INT_ARRAY"
	if(type == TYPE_REAL_ARRAY):
		return "TYPE_REAL_ARRAY"
	if(type == TYPE_STRING_ARRAY):
		return "TYPE_STRING_ARRAY"
	if(type == TYPE_VECTOR2_ARRAY):
		return "TYPE_VECTOR2_ARRAY"
	if(type == TYPE_VECTOR3_ARRAY):
		return "TYPE_VECTOR3_ARRAY"
	if(type == TYPE_COLOR_ARRAY):
		return "TYPE_COLOR_ARRAY"
	return "UNKNOWN_TYPE"

const spaceCharacters = {
	" ": true,
	"\t": true,
}

const digits = {
	"0": true,
	"1": true,
	"2": true,
	"3": true,
	"4": true,
	"5": true,
	"6": true,
	"7": true,
	"8": true,
	"9": true,
}

const asciiletters = {
	"a": true, "A": true,
	"b": true, "B": true,
	"c": true, "C": true,
	"d": true, "D": true,
	"e": true, "E": true,
	"f": true, "F": true,
	"g": true, "G": true,
	"h": true, "H": true,
	"i": true, "I": true,
	"j": true, "J": true,
	"k": true, "K": true,
	"l": true, "L": true,
	"m": true, "M": true,
	"n": true, "N": true,
	"o": true, "O": true,
	"p": true, "P": true,
	"q": true, "Q": true,
	"r": true, "R": true,
	"s": true, "S": true,
	"t": true, "T": true,
	"u": true, "U": true,
	"v": true, "V": true,
	"w": true, "W": true,
	"x": true, "X": true,
	"y": true, "Y": true,
	"z": true, "Z": true,
}

#█░
#▰▱
#◼▭
#▮▯
static func textProgressBar(value, barLetterSize = 15, fullLetter = "█", emptyLetter = "▁"):
	value = clamp(value, 0.0, 1.0)
	var amountOfFull = floor(barLetterSize * value)
	var amountOfEmpty = barLetterSize - amountOfFull
	
	var result = ""
	for _i in range(amountOfFull):
		result += fullLetter
	for _i in range(amountOfEmpty):
		result += emptyLetter
	
	return result

static func isBitEnabled(mask, index):
	return mask & (1 << index) != 0

static func enableBit(mask, index):
	return mask | (1 << index)

static func disableBit(mask, index):
	return mask & ~(1 << index)

static func dmgRangeStr(min_damage: int, max_damage: int):
	var damage1 = min_damage
	var damage2 = max_damage
	
	return str(damage1)+"-"+str(damage2)

static func dmgRangeArrayStr(damage: Array):
	return dmgRangeStr(damage[0], damage[1])

static func getStackFunction(depth = 2):
	var stack = get_stack()
	if(stack == null || !(stack is Array) || stack.size() <= (depth + 1)):
		return "No stack available"
	var text = "File: "+stack[depth]["source"]+" Line: "+str(stack[depth]["line"])
	return text

static func cmToString(cm):
	var measureUnits = OPTIONS.getMeasurementUnits()
	
	if(measureUnits == "metric"):
		return str(roundF(cm, 2))+" cm"
	
	if(measureUnits == "imperial"):
		return str(roundF(cm/2.54, 2))+" in"

	if(measureUnits == "metricimperial"):
		return str(roundF(cm, 2))+" cm"+"/"+str(roundF(cm/2.54, 2))+" in"
		
	return str(roundF(cm, 2))+" cm"

static func removeDirectory(path):
	var directory = Directory.new()
	
	# Open directory
	var error = directory.open(path)
	if error == OK:
		# List directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				removeDirectory(path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		
		# Remove current path
		directory.remove(path)
	else:
		print("Error removing " + path)

# input splitOnFirst("Test.Meow.Woof", ".")
# output ["Test", "Meow.Woof"]
static func splitOnFirst(text: String, separator: String):
	var stuff = text.split(separator)
	
	if(stuff.size() <= 1):
		return stuff
	
	var firstEntry = stuff[0]
	stuff.remove(0)
	
	return [firstEntry, join(stuff, separator)]

static func isArrayOfArrays(theArray: Array):
	if(theArray.size() == 0):
		return true
	
	if(theArray[0] is Array):
		return true
	return false

static func replaceIfNotNull(thestring, whattoreplace, replacewith):
	if(thestring == null || !(thestring is String)):
		return thestring
	return thestring.replace(whattoreplace, replacewith)

static func readFile(path):
	var file = File.new()
	var content = ""
	if file.open(path, file.READ) == OK:
		content = file.get_as_text()
	file.close()
	return content

static func writeFile(path, content):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

static func moveValueUp(theArray, theIndex):
	var thingie = theArray[theIndex]
	theArray.remove(theIndex)
	theIndex -= 1
	if(theIndex < 0):
		theIndex = 0
	theArray.insert(theIndex, thingie)

static func moveValueDown(theArray, theIndex):
	var thingie = theArray[theIndex]
	theArray.remove(theIndex)
	theIndex += 1
	if(theIndex > theArray.size()):
		theIndex = theArray.size()
	theArray.insert(theIndex, thingie)

# https://github.com/ShatReal/Search-Bar-Demo/blob/main/main.gd
static func _levenshtein_distance(str1:String, str2:String)->int:
	str1 = str1.to_lower()
	str2 = str2.to_lower()
	var m:int = len(str1)
	var n:int = len(str2)
	var d: Array = []
	for i in range(1, m+1):
		d.append([i])
	d.insert(0, range(0, n+1))
	for j in range(1, n+1):
		for i in range(1, m+1):
			var substitution_cost: int
			if str1[i-1] == str2[j-1]:
				substitution_cost = 0
			else:
				substitution_cost = 1
			d[i].insert(j, min(min(
				d[i-1][j]+1,
				d[i][j-1]+1),
				d[i-1][j-1]+substitution_cost))
	return d[-1][-1]

static func sanitizePlayerEnteredString(inputStr:String, emptyStr:String=""):
	inputStr = inputStr.replace("{", "")
	inputStr = inputStr.replace("}", "")
	inputStr = inputStr.replace("[", "")
	inputStr = inputStr.replace("]", "")
	inputStr = inputStr.replace("\"", "")
	if(inputStr == ""):
		return emptyStr
	return inputStr

static func remapValue(theValue:float, minValue:float, maxValue:float, newMinValue:float, newMaxValue:float):
	if(minValue == maxValue):
		assert(false, "remapValue got bad min and max values")
		return 0.0
	var percentage = (theValue - minValue) / (maxValue - minValue)
	
	var remappedValue = newMinValue + percentage * (newMaxValue - newMinValue)
	return remappedValue

static func ease_in_out(value:float):
	value = clamp(value, 0.0, 1.0)
	
	return value * value * (3.0 - 2.0*value)

# 0.0 = 0.0
# 0.5 = 1.0
# 1.0 = 0.0
static func distanceToHalfEased(value:float, halfpoint:float = 0.5):
	value = clamp(value, 0.0, 1.0)
	
	if(value < halfpoint):
		return ease_in_out(value / halfpoint)
	else:
		return ease_in_out(1.0 - (value-halfpoint)/(1.0 - halfpoint))

# 0.0 = 0.0
# 0.5 = 1.0
# 1.0 = 0.0
static func distanceToHalfWithIntervalEased(value: float, halfpoint: float = 0.5, intervalWidth: float = 0.1):
	value = clamp(value, 0.0, 1.0)

	if value < halfpoint - intervalWidth:
		return 0.0
	elif value < halfpoint:
		return ease_in_out((value - (halfpoint - intervalWidth)) / intervalWidth)
	elif value < halfpoint + intervalWidth:
		return ease_in_out(-(value - (halfpoint + intervalWidth)) / intervalWidth)
	else:
		return 0.0

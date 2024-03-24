extends Object
class_name RNG

# generates an [from,to] int, both are inclusive
static func randi_range(from: int, to: int) -> int:
	if(from > to):
		Log.printerr("randi_range() from is higher than to. From = "+str(from)+" To = "+str(to))
		to = from
	#assert(to >= from)
	
	var randValue = int(floor(rand_range(from, to+1)))
	if(randValue < from):
		randValue = from
	if(randValue > to):
		randValue = to
	
	return randValue
	# This way is bugged apparently?
	#return from + (randi() % (to - from + 1))

static func randf_range(from: float, to: float) -> float:
	return rand_range(from, to)

static func randf_rangeX2(from: float, to: float) -> float:
	return (rand_range(from, to) + rand_range(from, to)) / 2.0

# generates a number in the range with higher chance in the upper half
static func randf_rangeAdv(from: float, to: float) -> float:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var a = rng.randf_range(from, to)
	var b = rng.randf_range(from, to)
	var c = rng.randf_range(from, to)
	return (a + b + c - min(min(a, b), c)) / 2.0

# generates a number in the range with higher chance in the lower half
static func randf_rangeDis(from: float, to: float) -> float:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var a = rng.randf_range(from, to)
	var b = rng.randf_range(from, to)
	var c = rng.randf_range(from, to)
	return (a + b + c - max(max(a, b), c)) / 2.0

# chance(100) will always be true
# chance(3) will be true 3% of the time
static func chance(ch: float) -> bool:
	var randValue = randf() * 100
	if(ch >= randValue):
		return true
	return false
	
# picks a random element from an array or a random key from a dictionary
static func pick(ar):
	if(ar is Dictionary):
		ar = ar.keys()
		
	if(ar.empty()):
		return null
	
	return ar[randi() % ar.size()]

static func grab(ar):	
	if(ar is Dictionary):
		ar = ar.keys()
		
	if(ar.empty()):
		return null
	
	var elementI = randi() % ar.size()
	var value = ar[randi() % ar.size()]
	ar.remove(elementI)
	return value

# RNG.pickWeighted(["a", "b", "c"], [10, 100, 10]) # 'b' will show up 10 times more
static func pickWeighted(ar, weights: Array):
	if(ar is Dictionary):
		ar = ar.keys()
		
	assert(ar.size() == weights.size(), "Weights array doesn't have the same amount of elements as array")
	
	if(ar.empty()):
		return null
	
	var sum = 0.0
	for w in weights:
		sum += w
	
	var r:float = rand_range(0.0, sum)
	for i in range(weights.size()):
		r -= weights[i]
		if r <= 0.0:
			return ar[i]
			
	return ar[0]


# RNG.pickWeightedPairs([["a", 10.0], ["b", 100.0], ["c", 10.0]]) # 'b' will show up 10 times more
static func pickWeightedPairs(ar: Array):
	if(ar.empty()):
		return null
		
	var sum = 0.0
	for pair in ar:
		sum += pair[1]
		
	var r:float = rand_range(0.0, sum)
	for i in range(ar.size()):
		r -= ar[i][1]
		if r <= 0.0:
			return ar[i][0]
			
	return ar[0][0]

# Same as RNG.pickWeighted() but it also removes the picked entry from both arrays
static func grabWeighted(ar, weights: Array):
	if(ar is Dictionary):
		ar = ar.keys()
		
	assert(ar.size() == weights.size(), "Weights array doesn't have the same amount of elements as array")
	
	if(ar.empty()):
		return null
	
	var sum = 0.0
	for w in weights:
		sum += w
	
	var r:float = rand_range(0.0, sum)
	for i in range(weights.size()):
		r -= weights[i]
		if r <= 0.0:
			var result = ar[i]
			ar.remove(i)
			weights.remove(i)
			return result
			
	var result = ar[0]
	ar.remove(0)
	weights.remove(0)
	return result

# Same as RNG.pickWeightedPairs() but it also removes the picked entry from the array
static func grabWeightedPairs(ar: Array):
	if(ar.empty()):
		return null
		
	var sum = 0.0
	for pair in ar:
		sum += pair[1]
		
	var r:float = rand_range(0.0, sum)
	for i in range(ar.size()):
		r -= ar[i][1]
		if r <= 0.0:
			var result = ar[i][0]
			ar.remove(i)
			return result
			
	var result = ar[0][0]
	ar.remove(0)
	return result
	
static func randomMaleName():
	return pick(RNGData.maleNames)

static func randomFemaleName():
	return pick(RNGData.femaleNames)

static func pickHashed(ar, thehash:int):
	thehash = thehash % ar.size()
	return ar[thehash]

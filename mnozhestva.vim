"функции декартова произведения множеств для Екселя

function! Decart2(param1)
	"Считываем две строки -- одномерные или двумерные множества для перемножения, 
	"преобразовываем в одномерные списки, выполняем декартово
	"умножение множеств, возвращаем в читаемом виде.
	"если параметр1 = 0, печатаем для Екселя
	"если параметр1 = 1, печатаем для дальнейшего умножения
	let A1 = getline('.')
	let A2 = getline(line('.')+1)

	"обработать A1
	"пусть A1 имеет вид "(d10, d11), (d10, d12)" или "d10, d11"
	let A1 = substitute(A1, "\[' ]", "", "g")
	let A2 = substitute(A2, "\[' ]", "", "g")

	let A1toList = SplitToList(A1)
	let A2toList = SplitToList(A2)

	let A1XA2 = [ ]

	for i in A1toList
	  for j in A2toList
	    call add(A1XA2, [i, j])
	  endfor
	endfor
	"сейчас имеем двумерный массив

	if a:param1 == 0
		"преобразуем списки второго уровня в строки
		let joinedA1XA2 = []
		for iii in A1XA2
			let justHere = join(iii, ",")
			let justHere = substitute(justHere, ",", ", ", "g")
			let justHere = substitute(justHere, "^", "(", "")
			let justHere = substitute(justHere, "$", "),", "")
			call add(joinedA1XA2, justHere )
			unlet iii
			unlet justHere
		endfor
		call setline( line('$') + 1, "") "добавляем пустую строку-разделитель
		call append( line('$'), joinedA1XA2)
		call setline( line('$'), substitute(getline('$'), ",$", "", "") )
	elseif a:param1 == 1
		"на случай, если хочется в одной строке в виде множества
		let joinedX = join(A1XA2, ", ")
		let joinedX = substitute(joinedX, "[", "(", "g")
		let joinedX = substitute(joinedX, "]", ")", "g")
		let joinedX = substitute(joinedX, "'", "", "g")
		call setline(line('$')+1, "") "добавляем пустую строку-разделитель
		call setline(line('$')+1, joinedX) "если хочу этот массив в одной строке
	endif

	return A1XA2

endfunction

function! FindAllOuterBraces(mnzhvo)
	"получаем на входе строку с множествами
	"предполагается, что скобки расставлены правильно
	"на выходе выдаём двумерный массив индексов парных внешних скобок [ [индексОткр1, индексЗакр1 ] ...]
	"если параметр равен 1, функция принимает текущую строку
	if a:mnzhvo == 1
		let mnzhvo = getline('.')
	else
		let mnzhvo = a:mnzhvo
	endif
	"let mnzhvo = "   ((a,b), (c,d)), ((a,b), (e,f)), ((j,k), (c,d)), ((j,k), (e,f))"
	"let mnzhvo = "a,(b,c),d,e,(f,(g,h)),z,(b,c)"

	let pattern =  "\[()]" "на случай поиска другого паттерна в будущем
	let counter = match(mnzhvo, pattern)
	"если счётчик -1, значит, скобок нет!
	if counter == -1
		return "скобок, вроде, нету"
	endif
	let stack = [counter]
	let counter = counter + 1
	let bracelist = []
	while counter < strlen(mnzhvo)
		let counter = match(mnzhvo, pattern, counter) "ищем следующую скобку ( или )
		if counter == -1
			break
		endif
		if mnzhvo[counter] == ')'
			if len(stack) == 1
				call add(bracelist, [remove(stack, -1), counter])
			else
				call remove(stack, -1) "пока что вложенные скобки нас не волнуют
			endif
			let counter = counter + 1
		elseif mnzhvo[counter] == '('
			call add(stack, counter)
			let counter = counter + 1
		else
			return "something bad with match(".pattern."\""
		endif
	endwhile

	return bracelist
endfunction

function! FindClosingBrace(string)
	"получаем на входе строку с открывающей скобкой первым символом
	"предполагается, что скобки расставлены правильно
	"на выходе выдаём индекс закрывающей скобки
	"если параметр равен 1, функция принимает текущую строку из текста
	if a:string == 1
		let string = getline('.')
	else
		let string = a:string
	endif
	"let string = "((a,b), (c,d)), ((a,b), (e,f)), ((j,k), (c,d)), ((j,k), (e,f))"
	"let string = "(b,c),d,e,(f,(g,h)),z,(b,c)"
	"let string = "( ()()  )"

	let pattern =  "\[()]" "на случай поиска другого паттерна в будущем
	let counter = match(string, pattern, 1) "первый символ и так скобка, правильно?
	"если счётчик -1, значит, закрывающей скобки не найдено. Что делать?
	if string[counter] == ')'
		return counter 				"нашли
	elseif counter == -1
		return "Error 1. скобки закрывающей нету!, проверь строку!"
	endif

	let stack = [counter]
	let counter = counter + 1
	while counter < strlen(string)
		let counter = match(string, pattern, counter) "ищем следующую скобку ( или )
		if counter == -1
			return "Error 2. скобки закрывающей нету!"
		endif
		if string[counter] == ')'
			if len(stack) == 0
				return counter 				"нашли
			endif
			call remove(stack, -1) "пока что вложенные скобки нас не волнуют
			let counter = counter + 1
		elseif string[counter] == '('
			call add(stack, counter)
			let counter = counter + 1
		else
			return "Error 3. Something bad with match(".pattern."\""
		endif
	endwhile

	return "Error 4. какая-то хрень с циклом, или строка начинается не со скобки"
endfunction


function! SplitToList(strToSplit)
	"получаем строку, разбиваем в одномерный массив по скобкам (если есть)
	"или запятым
	"строка -- правильное множество без ошибок в записи (пока)
	"в элементах множества нет скобок, запятых и пробелов
	let strToSplit = a:strToSplit
	let strToSplit = substitute(strToSplit, " ", "", "g")

	let counter = 0
	let splitted = []
	let pattern = "\[,(]" 
	
	while match(strToSplit, pattern) != -1
		let braceColon = match(strToSplit, pattern, counter)
		if strToSplit[braceColon] == ","
			call add(splitted, strpart(strToSplit, 0, braceColon))
			let strToSplit = strpart(strToSplit, braceColon + 1)
		elseif strToSplit[braceColon] == "("
			let closingBrace = FindClosingBrace(strToSplit)
			if match(closingBrace, "Error") > 0
				"обработка ошибок
				return closingBrace
			endif
			"удалим пробел перед скобкой, если есть
			"if strToSplit[0] == " "
			"	let strToSplit = strpart(strToSplit, 1)
			"	"return strToSplit
			"endif
			call add(splitted, strpart(strToSplit, 0, closingBrace + 1))
			let strToSplit = strpart(strToSplit, closingBrace + 2)
		endif
		let counter = 0
	endwhile

	"обрабатываем "хвостик"
	if len(strToSplit) > 0
		call add(splitted, strToSplit)
	endif

	"let splitted = "сделай до конца"
	return splitted
endfunction

function! Decart1()
	"ЭТО БЫЛ ПЕРВЫЙ ПРОБНЫЙ
	"Считываем две строки -- множества для перемножения, 
	"преобразовываем в списки, выполняем декартово
	"умножение множеств, возвращаем в читаемом виде.
	let A1 = getline('.')
	let A2 = getline(line('.')+1)

	"обработать A1
	"пусть A1 имеет вид 'd10, d11'
	let A1 = substitute(A1, "\[' ]", "", "g")
	let A2 = substitute(A2, "\[' ]", "", "g")

	let A1toList = split(A1, ',')
	let A2toList = split(A2, ',')

	let A1XA2 = [ ]

	for i in A1toList
	  for j in A2toList
	    call add(A1XA2, [i, j])
	  endfor
	endfor
	"сейчас имеем двумерный массив

	"START variant1
	"если хочу этот массив в виде разбитых на строки элементов массива
	let joinedX = join(A1XA2, ", ")
	let joinedX = substitute(joinedX, "[", "(", "g")
	let joinedX = substitute(joinedX, "]", ")", "g")
	let joinedX = substitute(joinedX, "'", "", "g")

	"конструкция \(foo\)\@<= -- поиск foo нулевой длины перед ", "
	let joinedXtoList = split(joinedX, '\()\)\@<=, ')

	call setline(line('$')+1, joinedXtoList)
	"
	"END variant1

	return 1

endfunction


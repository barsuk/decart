"������� ��������� ������������ �������� ��� ������

function! Decart2(param1)
	"��������� ��� ������ -- ���������� ��� ��������� ��������� ��� ������������, 
	"��������������� � ���������� ������, ��������� ���������
	"��������� ��������, ���������� � �������� ����.
	"���� ��������1 = 0, �������� ��� ������
	"���� ��������1 = 1, �������� ��� ����������� ���������
	let A1 = getline('.')
	let A2 = getline(line('.')+1)

	"���������� A1
	"����� A1 ����� ��� "(d10, d11), (d10, d12)" ��� "d10, d11"
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
	"������ ����� ��������� ������

	if a:param1 == 0
		"����������� ������ ������� ������ � ������
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
		call setline( line('$') + 1, "") "��������� ������ ������-�����������
		call append( line('$'), joinedA1XA2)
		call setline( line('$'), substitute(getline('$'), ",$", "", "") )
	elseif a:param1 == 1
		"�� ������, ���� ������� � ����� ������ � ���� ���������
		let joinedX = join(A1XA2, ", ")
		let joinedX = substitute(joinedX, "[", "(", "g")
		let joinedX = substitute(joinedX, "]", ")", "g")
		let joinedX = substitute(joinedX, "'", "", "g")
		call setline(line('$')+1, "") "��������� ������ ������-�����������
		call setline(line('$')+1, joinedX) "���� ���� ���� ������ � ����� ������
	endif

	return A1XA2

endfunction

function! FindAllOuterBraces(mnzhvo)
	"�������� �� ����� ������ � �����������
	"��������������, ��� ������ ����������� ���������
	"�� ������ ����� ��������� ������ �������� ������ ������� ������ [ [����������1, ����������1 ] ...]
	"���� �������� ����� 1, ������� ��������� ������� ������
	if a:mnzhvo == 1
		let mnzhvo = getline('.')
	else
		let mnzhvo = a:mnzhvo
	endif
	"let mnzhvo = "   ((a,b), (c,d)), ((a,b), (e,f)), ((j,k), (c,d)), ((j,k), (e,f))"
	"let mnzhvo = "a,(b,c),d,e,(f,(g,h)),z,(b,c)"

	let pattern =  "\[()]" "�� ������ ������ ������� �������� � �������
	let counter = match(mnzhvo, pattern)
	"���� ������� -1, ������, ������ ���!
	if counter == -1
		return "������, �����, ����"
	endif
	let stack = [counter]
	let counter = counter + 1
	let bracelist = []
	while counter < strlen(mnzhvo)
		let counter = match(mnzhvo, pattern, counter) "���� ��������� ������ ( ��� )
		if counter == -1
			break
		endif
		if mnzhvo[counter] == ')'
			if len(stack) == 1
				call add(bracelist, [remove(stack, -1), counter])
			else
				call remove(stack, -1) "���� ��� ��������� ������ ��� �� �������
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
	"�������� �� ����� ������ � ����������� ������� ������ ��������
	"��������������, ��� ������ ����������� ���������
	"�� ������ ����� ������ ����������� ������
	"���� �������� ����� 1, ������� ��������� ������� ������ �� ������
	if a:string == 1
		let string = getline('.')
	else
		let string = a:string
	endif
	"let string = "((a,b), (c,d)), ((a,b), (e,f)), ((j,k), (c,d)), ((j,k), (e,f))"
	"let string = "(b,c),d,e,(f,(g,h)),z,(b,c)"
	"let string = "( ()()  )"

	let pattern =  "\[()]" "�� ������ ������ ������� �������� � �������
	let counter = match(string, pattern, 1) "������ ������ � ��� ������, ���������?
	"���� ������� -1, ������, ����������� ������ �� �������. ��� ������?
	if string[counter] == ')'
		return counter 				"�����
	elseif counter == -1
		return "Error 1. ������ ����������� ����!, ������� ������!"
	endif

	let stack = [counter]
	let counter = counter + 1
	while counter < strlen(string)
		let counter = match(string, pattern, counter) "���� ��������� ������ ( ��� )
		if counter == -1
			return "Error 2. ������ ����������� ����!"
		endif
		if string[counter] == ')'
			if len(stack) == 0
				return counter 				"�����
			endif
			call remove(stack, -1) "���� ��� ��������� ������ ��� �� �������
			let counter = counter + 1
		elseif string[counter] == '('
			call add(stack, counter)
			let counter = counter + 1
		else
			return "Error 3. Something bad with match(".pattern."\""
		endif
	endwhile

	return "Error 4. �����-�� ����� � ������, ��� ������ ���������� �� �� ������"
endfunction


function! SplitToList(strToSplit)
	"�������� ������, ��������� � ���������� ������ �� ������� (���� ����)
	"��� �������
	"������ -- ���������� ��������� ��� ������ � ������ (����)
	"� ��������� ��������� ��� ������, ������� � ��������
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
				"��������� ������
				return closingBrace
			endif
			"������ ������ ����� �������, ���� ����
			"if strToSplit[0] == " "
			"	let strToSplit = strpart(strToSplit, 1)
			"	"return strToSplit
			"endif
			call add(splitted, strpart(strToSplit, 0, closingBrace + 1))
			let strToSplit = strpart(strToSplit, closingBrace + 2)
		endif
		let counter = 0
	endwhile

	"������������ "�������"
	if len(strToSplit) > 0
		call add(splitted, strToSplit)
	endif

	"let splitted = "������ �� �����"
	return splitted
endfunction

function! Decart1()
	"��� ��� ������ �������
	"��������� ��� ������ -- ��������� ��� ������������, 
	"��������������� � ������, ��������� ���������
	"��������� ��������, ���������� � �������� ����.
	let A1 = getline('.')
	let A2 = getline(line('.')+1)

	"���������� A1
	"����� A1 ����� ��� 'd10, d11'
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
	"������ ����� ��������� ������

	"START variant1
	"���� ���� ���� ������ � ���� �������� �� ������ ��������� �������
	let joinedX = join(A1XA2, ", ")
	let joinedX = substitute(joinedX, "[", "(", "g")
	let joinedX = substitute(joinedX, "]", ")", "g")
	let joinedX = substitute(joinedX, "'", "", "g")

	"����������� \(foo\)\@<= -- ����� foo ������� ����� ����� ", "
	let joinedXtoList = split(joinedX, '\()\)\@<=, ')

	call setline(line('$')+1, joinedXtoList)
	"
	"END variant1

	return 1

endfunction


" AutoHotkey_SIDE ( Simple IDE )

" Last Change:  2013-03-19 10:11:59
" Initialize {{{
" Set the path of Autohotkey.exe
if !exists('g:AhkSIDE_AhkExe')
" {{{
	if executable('<sfile>:p:h\autohotkey.exe')
		let g:AhkSIDE_AhkExe  = expand('<sfile>:p:h\autohotkey.exe')
	elseif executable($ProgramFiles . '\autohotkey\autohotkey.exe')
		let g:AhkSIDE_AhkExe = $ProgramFiles . '\autohotkey\autohotkey.exe'
	else
		echomsg 'g:AhkSIDE_AhkExe isn''t set !'
	endif
elseif !executable(g:AhkSIDE_AhkExe)
	echomsg 'Can''t find autohotkey.exe !'
" }}}
endif

" Set the path of autohotkey.chm
if !exists('g:AhkSIDE_AhkChm')
" {{{
	if executable('<sfile>:p:h\autohotkey.chm')
		let g:AhkSIDE_AhkChm = expand('<sfile>:p:h\autohtokey.chm')
	elseif executable($ProgramFiles . '\autohotkey\autohotkey.chm')
		let g:AhkSIDE_AhkChm = $ProgramFiles . '\autohotkey\autohotkey.chm'
	else
		echomsg 'g:AhkSIDE_AhkChm isn''set !'
	endif
elseif !executable(g:AhkSIDE_AhkChm)
	echomsg 'Can''t find autohotkey.chm'
" }}}
endif

if !exists('tlist_autohotkey_settings')
	let tlist_autohotkey_settings = 'ahk;k:Hotkeys;s:Hotstrings;l:Labels;f:Functions'
endif

" g:AhkRunningFile

" g:AhkOmniComplData, g:AhkHints, g:AhkHintsKeys
if !exists('g:AhkOmniComplData')
" Parse API file {{{
	" If 'ahk.api' Exist
	if filereadable(expand('<sfile>:p:h') . '\ahk.api')
		" Load 'ahk.api'.
		let s:ApiFile = readfile(expand('<sfile>:p:h') . '\ahk.api')

		" Load 'user.ahk.api'
		if filereadable(expand('<sfile>:p:h') . '\user.ahk.api')
			call extend(s:ApiFile,readfile(expand('<sfile>:p:h') . '\user.ahk.api'))
		endif

		call sort(s:ApiFile)

		let g:AhkOmniComplData = []
		let g:AhkHints = {}
		"let g:AhkHintsKeys = []

		" Parse AhkFile {{{
		for s:l in s:ApiFile
			" Remove the white char in line end
			let s:l = substitute(s:l,'\s\+$','','')

			" Skip empty line
			if strlen(s:l) == 0
				continue
			endif

			" Get the Word part (g:AhkOmniComplData) {{{
			let s:w = matchstr(s:l,'^.\{-}\ze\s')

			" Only word part
			if strlen(s:w) == 0
				call add(g:AhkOmniComplData,s:l)
				continue
			endif " }}}

			" Get the Info part (g:AhkHints) {{{
			call add(g:AhkOmniComplData,s:w)
			call extend(g:AhkHints,{s:w : substitute(s:l,'\\n','\n','g')})
			" }}}
		endfor " }}}

		let g:AhkHintsKeys = keys(g:AhkHints)
		unlet s:ApiFile s:w s:l
	else
		echoerr 'Can''t find ahk.api'
	endif
" }}}
endif

if !exists('*Ahk_cword')
" Functions {{{
" Ahk_cword() {{{
" Return cword in 'Insert' mode
function! Ahk_cword()
	let line = getline('.')
	let end = col('.') - 1
	let start = end
	let len = strlen(line)

	" Find the word start.
	while start > 0 && line[start -1] =~ '\w\|#'
		let start -= 1
	endwhile

	" Find the word end.
	while end < len && line[end +1] =~ '\w\|('
		let end += 1
		if line[end] == '('
			break
		endif
	endwhile

	return strpart(line,start,end - start + 1) . ( line[end] == '(' ? ')' : '' )
endfunction " }}}

" AhkInfoWnd_...() {{{
" AhkInfoWnd_Init() {{{
function! AhkInfoWnd_Init()
	let l:WndNr = winnr()
	belowright pedit +set\ nobuflisted\|5wincmd\ _ AhkInfoWnd

	let l:ei_org = &eventignore
	set eventignore=all
	wincmd P

	setlocal buftype=nofile nonumber
	setlocal filetype=ahkinfownd
	let g:AhkInfoBufNr = bufnr('')

	" Set Syntax Highlight {{{
	syn match ahkinfowndLS '^\%(AhkExe:\|Script:\|Running\|ExitCode:\)' contains=ahkinfowndFc
	syn match ahkinfowndLError '.\+(\d\+) : ==>.\+' contains=ahkinfowndFcErrorLineNr

	hi def link ahkinfowndLS StorageClass
	hi def link ahkinfowndLError Error
	" }}}

	execute l:WndNr.'wincmd w'
	let &eventignore = l:ei_org
endfunction
" }}}

" AhkInfoWnd_SetText(txt) {{{
function! AhkInfoWnd_SetText(txt)
	if strlen(a:txt) > 0
		" Check if AhkInfoWnd initialized
		if !exists('g:AhkInfoBufNr')
			call AhkInfoWnd_Init()
		endif

		let l:WndNr = winnr()

		" Check if preview window exists.
		if bufwinnr(g:AhkInfoBufNr) == -1
			belowright pedit +set\ nobuflisted\|5wincmd\ _ AhkInfoWnd
		endif

		let l:ei_org = &eventignore
		set eventignore=all
		wincmd P

		setl modifiable
		%delete _
		call setline('.',split(a:txt,"\n"))
		setl nomodifiable
		redraw

		execute l:WndNr.'wincmd w'
		let &eventignore = l:ei_org
		return 1
	else
		return 0
	endif
endfunction
" }}}

" AhkInfoWnd_AppendText(txt) {{{
function! AhkInfoWnd_AppendText(txt)
	" AppendText only valid for preview window already exist.
	if strlen(a:txt) < 1 || bufwinnr(g:AhkInfoBufNr) == -1
		return 0
	endif

	let l:WndNr = winnr()
	let l:ei_org = &eventignore
	set eventignore=all
	wincmd P

	setlocal modifiable
	call append(line('$'),split(a:txt,"\n"))
	setlocal nomodifiable
	redraw

	execute l:WndNr.'wincmd w'
	let &eventignore = l:ei_org
	return 1
endfunction
" }}}

" AhkInfoWnd_GoToErrorLine() {{{
function! AhkInfoWnd_GoToErrorLine()
	if !exists('g:AhkInfoBufNr')
		return 0
	endif
	let AhkInfo = getbufline(g:AhkInfoBufNr,1,'$')
	if len(AhkInfo) > 3
		execute 'normal ' . matchstr(AhkInfo[3],'(\zs\d\+\ze)') . 'G^'
	endif
endfunction " }}}
" }}}

" AhkShowHints() {{{
function! AhkShowHints()
	" Get 'identifier' {{{
	let line = getline('.')

	" If in line end, don't trim the string.
	if strlen(line) > col('.')
		let line = strpart(line,0,col('.')-1)
	endif

	" Find the rightest function
	if match(line,'\w(') > -1
		let l:count = 1
		while match(line,'\w(',0,l:count+1) > -1
			let l:count += 1
		endwhile
		" The '\w\+(' will match recursively ...
		let word = matchstr(line,'\<\w\+(\@=',0,l:count)

	" If function isn't found, find the leftest command
	else
		" substitute(): remove Hotkey, Hotstring labels.
		let word = matchstr(substitute(substitute(getline('.')
					\ ,'^\s*:\?[^:]*:\?\p\+::','','')
					\ ,'^\s*\w\+:','','')
					\ ,'#\?\a\+')
	endif " }}}
	" Show Hints " {{{
	" Unable to use 'has_key()' simply. The 'key' of the dictionary is case-sensitive.
	let flag = 0
	for i in g:AhkHintsKeys
		if i ==? word
			call AhkInfoWnd_SetText(g:AhkHints[i])
			break
		endif
	endfor " }}}
endfunction
" }}}

" AhkRunStopScript(fg_Run) {{{
function! AhkRunStopScript(fg_Run,...)
	" fg_Run = 1,  Script run. " {{{
	if a:fg_Run == 1
		update
		let g:AhkRunningFile=expand('%:p')
		let g:AhkInfo = "AhkExe: " . g:AhkSIDE_AhkExe . "\nScript: " . g:AhkRunningFile . "\nRunning"
		"let g:AhkInfo = "AhkExe: " . g:AhkSIDE_AhkExe . "\nScript: " . g:AhkRunningFile
		call AhkInfoWnd_SetText(g:AhkInfo)
	" }}}
	" fg_Run != 1, Script stop. " {{{
	else
		"call AhkInfoWnd_SetText(g:AhkInfoStop)
		call AhkInfoWnd_SetText(a:1)
		unlet g:AhkRunningFile
	endif " }}}
endfunction " }}}

" AhkOmniFunc(findstart,base) {{{
function! AhkOmniFunc(findstart, base)
" First Time {{{
	if a:findstart
		let line = getline('.')
		let start = col('.') - 1

		" Find the leftest non-blank character.
		while start > 0 && line[start - 1] =~ '\w\|#'
			let start -= 1
		endwhile

		return start " }}}
" Second Time {{{
	else
		"let res = []
		let res = [a:base]
		for m in g:AhkOmniComplData
			if m =~? '^' . a:base
				call add(res,m)
				if complete_check()
					break
				endif
			endif
		endfor
		"call add(res,a:base)
		return res
	endif " }}}
endfunction " }}}
" }}}
endif

if !exists('g:AhkSIDE_hk_in_GoToErrorLine')
	let g:AhkSIDE_hk_in_GoToErrorLine = '<F4>'
endif
execute 'inoremap <silent><buffer> ' . g:AhkSIDE_hk_in_GoToErrorLine . ' <C-o>:call AhkInfoWnd_GoToErrorLine()<CR>'
execute 'nnoremap <silent><buffer> ' . g:AhkSIDE_hk_in_GoToErrorLine . ' :call AhkInfoWnd_GoToErrorLine()<CR>'

if !exists('g:AhkSIDE_hk_i_ShowHints')
	let g:AhkSIDE_hk_i_ShowHints = '<C-z>'
endif
execute 'inoremap <buffer> ' . g:AhkSIDE_hk_i_ShowHints . ' <C-o>:call AhkShowHints()<CR>'

" AhkSIDE.exe {{{
if !exists('g:AhkSIDE_hk_in_Help')
	let g:AhkSIDE_hk_in_Help = 'F1'
endif

if !exists('g:AhkSIDE_hk_in_RunScript')
	let g:AhkSIDE_hk_in_RunScript = 'F5'
endif

if !exists('g:AhkSIDE_hk_in_StopScript')
	let g:AhkSIDE_hk_in_StopScript = 'F6'
endif

if !exists('g:fgAhkSIDE') && executable(g:AhkSIDE_AhkExe) && executable(g:AhkSIDE_AhkChm)
	execute 'silent !start ' . expand('<sfile>:p:h') . '\AhkSIDE.Exe'
	let g:fgAhkSIDE = 1
endif " }}}
"}}}

setlocal omnifunc=AhkOmniFunc
setlocal comments=s1:/*,mb:*,ex:*/,f:;-,b:; formatoptions=croql
setlocal commentstring=;\ %s
setlocal include=^\\s*#[Ii]nclude\\s*\\zs.*\\ze\\%(\\s*\\\|\\s*;.*\\)$

" Set 'path' {{{
" Standard Library by $USERPROFILE or $HOME
execute 'setlocal path=.,,' . substitute(escape(expand('$USERPROFILE'),'\'),' ','\\\\\\ ','g') . '\\AutoHotkey\\Lib'
" Scan Script File {{{
let s:AhkFile = getbufline('%',1,'$')
for s:line in s:AhkFile
	" Remove comment
	let s:line = substitute(s:line,'\s*;.*$','','')

	" SetWorkingDir
	if s:line =~ '^\s*SetWorkingDir'
		if matchstr(s:line,'\s*SetWorkingDir\s*\zs.*') != '%A_ScriptDir%'
			execute 'setlocal path+=' . substitute(escape(matchstr(s:line,'\s*SetWorkingDir\s*\zs.*'),'\'),' ','\\\\\\ ','g')
		endif
	endif

	" #include and #includeAgain. #IncludeAgain can be ignored.
	if s:line =~ '^\s*#include.*\%(ahk\)\@<!$'
		execute 'setlocal path+=' . substitute(escape(matchstr(s:line,'\s*#include\s*\zs.*'),'\'),' ','\\\\\\ ','g')
	endif
endfor
unlet s:AhkFile s:line
" }}}
" }}}

" vim: fdm=marker tw=0 ts=4 sw=4

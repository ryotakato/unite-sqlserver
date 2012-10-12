let s:save_cpo = &cpo
set cpo&vim

let s:root = expand("<sfile>:p:h")

function! sqlserver#root()
	echo s:root
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo


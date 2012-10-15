let s:save_cpo = &cpo
set cpo&vim


let g:unite_sqlserver_server_pc =
      \ get(g:, 'unite_sqlserver_server_pc', '127.0.0.1')
let g:unite_sqlserver_user_name =
      \ get(g:, 'unite_sqlserver_user_name', '')
let g:unite_sqlserver_pass_word =
      \ get(g:, 'unite_sqlserver_pass_word', '')

let s:root = expand("<sfile>:p:h")

function! unite_sqlserver#root()
  return s:root
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo


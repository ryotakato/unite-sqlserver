"----------------------------------------------------------+
" get sqlserver info                                       |
"----------------------------------------------------------+
let s:save_cpo = &cpo
set cpo&vim

let s:pre_db = ""
let s:pre_tbl = ""

let s:source = {
\   'name': 'sqlserver',
\   'description': 'candidates from SQL Server',
\   'action_table': {},
\ }

" define source
function! unite#sources#sqlserver#define()
  return unite#util#has_vimproc() 
			  \ ? [s:source]
			  \ : []
endfunction

" main process of mongodb
function! s:source.gather_candidates(args, context) "{{{
  let a_count = len(a:args)

  let db_name = s:pre_db
  let tbl_name = s:pre_tbl

  if (a_count == 1)
	let db_name = a:args[0]
  elseif (a_count == 2)
	let db_name = a:args[0]
	let tbl_name = a:args[1]
  end

  if (db_name != "" && tbl_name != "" ) 
	let s:pre_db = db_name
	let s:pre_tbl = tbl_name
    return s:clm_list(db_name, tbl_name)
  elseif (db_name != "" )
	let s:pre_db = db_name
    return s:tbl_list(db_name)
  else
    return s:db_list()
  end


endfunction "}}}

" main process of db 
function! s:db_list() "{{{

  call unite#print_source_message('SQLServer > ', s:source.name)

  let dbs = s:get_db_list()
 
  return map(copy(dbs), '{
  \   "word": v:val,
  \   "source": "sqlserver",
  \   "kind": "source",
  \   "action__source_name": [s:source.name, v:val],
  \ }')
endfunction "}}}

" main process of tbl
function! s:tbl_list(db_name) "{{{
 
  call unite#print_source_message('SQLServer > '.a:db_name.' > ' , s:source.name)
  
  let tbls = s:get_tbl_list(a:db_name)
  
  return map(copy(tbls), '{
  \   "word": v:val,
  \   "source": "sqlserver",
  \   "kind": "source",
  \   "action__source_name": [s:source.name, a:db_name, v:val],
  \ }')
endfunction "}}}

" main process of column
function! s:clm_list(db_name, tbl_name) "{{{
 
  call unite#print_source_message('SQLServer > '.a:db_name.' > '.a:tbl_name.' > ' , s:source.name)

  let clms = s:get_clm_list(a:db_name, a:tbl_name)

  return map(copy(clms), '{
  \   "word": substitute(v:val, " .*$", "", "g"),
  \   "abbr": v:val,
  \   "source": s:source.name,
  \ }')
endfunction "}}}


" cache {{{
let s:cache = {}

let s:root = substitute(unite_sqlserver#root(), '\', '\\\\', 'g')

function! s:batch_path(batch_file_name)
  return '"'.s:root.'\\\\'.a:batch_file_name.'"'
endfunction

let s:server_pc = g:unite_sqlserver_server_pc
let s:user_name = g:unite_sqlserver_user_name
let s:pass_word = g:unite_sqlserver_pass_word

function! s:get_db_list()

  if (empty(s:cache))
    let dbs_line = vimproc#system(s:batch_path('info-db.bat').' '.s:server_pc.' '.s:user_name.' '.s:pass_word)
    let dbs_line = substitute(dbs_line, '\s*', '', 'g')
    let dbs = split(dbs_line, '\n')

    for db in dbs
      let s:cache[db] = {}
	  unlet db
	endfor
  endif

  return sort(copy(keys(s:cache)))
endfunction

function! s:get_tbl_list(db_name)
  if (empty(s:cache[a:db_name]))
    let tbls_line = vimproc#system(s:batch_path('info-tbl.bat').' '.s:server_pc.' '.s:user_name.' '.s:pass_word.' '.a:db_name)
    let tbls_line = substitute(tbls_line, '\s*', '', 'g')
    let tbls = split(tbls_line, '\n')

    for tbl in tbls
      let s:cache[a:db_name][tbl] = []
	  unlet tbl
	endfor
  endif

  return sort(copy(keys(s:cache[a:db_name])))
endfunction


function! s:get_clm_list(db_name, tbl_name)
  if (empty(s:cache[a:db_name][a:tbl_name]))
    let clms_line = vimproc#system(s:batch_path('info-column.bat').' '.s:server_pc.' '.s:user_name.' '.s:pass_word.' '.a:db_name.' '.a:tbl_name)

    "let clms_line = substitute(clms_line, '\s*', '', 'g')
    let clms = split(clms_line, '\n')

	for clm in clms
      call add(s:cache[a:db_name][a:tbl_name], clm)
	  unlet clm
	endfor
	  
  endif

  return copy(s:cache[a:db_name][a:tbl_name])
endfunction

"}}}


" custom action {{{

let s:sqlserver_back_action = {
      \ 'description' : 'back to upper db',
	  \ }

function! s:sqlserver_back_action.func(candidate) "{{{
  if s:pre_db != "" && s:pre_tbl != ""
	let s:pre_tbl = ""
  elseif s:pre_db != ""
	let s:pre_db = ""
  endif

  call unite#quit_session()
  call unite#start([[s:source.name]])
endfunction "}}}


call unite#custom_action('source/sqlserver/*', 'back', s:sqlserver_back_action)
unlet s:sqlserver_back_action
" }}}


" keymapping {{{

autocmd FileType unite call s:sqlserver_keymapping()
function! s:sqlserver_keymapping()
  let unite = unite#get_current_unite()
  for source in unite.sources
    if source.name ==# s:source.name
	  nnoremap <silent><buffer><expr> <Plug>(unite_sqlserver_back) unite#do_action('back')
	endif
  endfor
endfunction

"}}}

let &cpo = s:save_cpo
unlet s:save_cpo


" vim: foldmethod=marker

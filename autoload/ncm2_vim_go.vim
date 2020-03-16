if get(s:, 'loaded', 0)
    finish
endif
let s:loaded = 1

function! ncm2_vim_go#on_complete(ctx) abort
    let [l:line, l:col] = go#lsp#lsp#Position()
    call go#lsp#Completion(a:ctx.filepath, l:line, l:col, function('s:modify_completion_items', [a:ctx]))
endfunction

function! s:modify_completion_items(ctx, start, items) abort
    call ncm2#complete(a:ctx, a:ctx.startccol, map(a:items, function('s:add_snippets_for_funcs')))
endfunction

let s:func_patterns = [
        \ '\vfunc\((.*)\) \(.*\)(\n|$)',
        \ '\vfunc\((.*)\) .*(\n|$)',
        \ '\vfunc\((.*)\)(\n|$)',
        \ ]

function! s:add_snippets_for_funcs(idx, item) abort
    if get(a:item, 'kind', '') !=# 'f' || get(a:item, 'info', '') == ''
        return a:item
    endif

    for l:pat in s:func_patterns
        let l:results = matchlist(a:item['info'], l:pat)
        if len(l:results) > 0
            break
        endif
    endfor
    if len(l:results) < 2
        return a:item
    endif

    "results[1]: 'a int, b func(), c string'
    let l:snip_params = map(split(l:results[1], ','), function('s:render_snippet'))
    let a:item['user_data'] = {
            \ 'is_snippet': 1,
            \ 'snippet': a:item['word'] . '(' . join(l:snip_params, ', ') . ')${0}',
            \ }
    return a:item
endfunction

" param: ' c string'
function! s:render_snippet(i, param)
    " the escaping is weird; {} needs to be turned to {\} to pass thru
    " ncm2_ultisnips and come out as \{\}
    let l:snip_argument = substitute(trim(a:param), '{}', '{\\}', 'g')
    return printf('${%d:%s}', a:i+1, l:snip_argument)
endfunction

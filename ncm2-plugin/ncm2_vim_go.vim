let s:source = extend(
            \ get(g:, 'ncm2_vim_go#source', {}), {
            \ 'name': 'gopls',
            \ 'priority': 9,
            \ 'mark': 'go',
            \ 'early_cache': 1,
            \ 'subscope_enable': 1,
            \ 'scope': ['go'],
            \ 'word_pattern': '[\w/]+',
            \ 'complete_pattern': ['\.', '::'],
            \ 'on_complete': 'ncm2_vim_go#on_complete',
            \ }, 'keep')

call ncm2#register_source(s:source)

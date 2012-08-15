"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"fix loading of ftdetect scripts
filetype off

"activate pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set number      "show line numbers

"display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅


set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set wrap        "dont wrap lines
"set linebreak   "wrap lines at convenient points

if v:version >= 703
    "undo settings
    set undodir=~/.vim/undofiles
    set undofile

    set colorcolumn=+1 "mark the ideal max text width
endif

"default indent settings
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*/.git/*,*/build/*,*/build.*/*,*.o,*.obj,*~ "stuff to ignore when tab completing

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"tell the term has 256 colors
set t_Co=256

"hide buffers when not displayed
set hidden

"always show statusline
set laststatus=2
set encoding=utf-8

"syntastic settings
let g:syntastic_enable_signs=1
let g:syntastic_auto_loc_list=2
let g:syntastic_cpp_compiler_options = ' -std=c++0x'
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['cpp'] }

"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 40

"explorer mappings
nnoremap <f1> :BuffergatorToggle<cr>
nnoremap <f2> :NERDTreeToggle<cr>
nnoremap <f3> :TagbarToggle<cr>
nnoremap <f4> :GundoToggle<cr>

"source project specific config files
runtime! projects/**/*.vim

"dont load csapprox if we no gui support - silences an annoying warning
if !has("gui")
    let g:CSApprox_loaded = 1
endif

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'svn\|commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"spell check when writing commit logs
autocmd filetype svn,*commit* setlocal spell

"http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/
"hacks from above (the url, not jesus) to delete fugitive buffers when we
"leave them - otherwise the buffer list gets poluted
"
"add a mapping on .. to view parent tree
autocmd BufReadPost fugitive://* set bufhidden=delete
autocmd BufReadPost fugitive://*
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"start my additions
"

"set colorscheme
colorscheme koehler
"colorscheme default

"make running commands less ugly
set norestorescreen
set t_ti= t_te=

"disable backup since most stuff are in git
set nobackup

"disable bells
set visualbell t_vb=

"more include paths for gf command
set path+=/usr/include/c++/4.7.1

"override make command for CMake projects
function! Compile()
    if filereadable("CMakeLists.txt") && filereadable("./build/Makefile")
        set makeprg=make\ -j8\ -C\ build
    else
        set makeprg=make\ -j8
    endif
    make
endfunction

"command for bulding local tags
command! Ctags :!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q .

"fast vimrc editing
map <leader>v :e! ~/.vimrc<CR>
autocmd bufwritepost .vimrc source ~/.vimrc

"allow switching windows while in insert mode
imap <C-w> <Esc><C-w>

"ctrl space for omni code completion
imap <Nul> <C-X><C-O><S-Tab>
imap <C-space> <C-X><C-O><S-Tab>

"turn off needless toolbar on gvim
set guioptions-=T

"toggle spell checking
nmap <silent> <leader>s :set spell!<CR>
set spelllang=en

"key mapping for quickfix navigation
map <C-n> :cnext<CR>
map <C-b> :cprevious<CR>

" allow larger text width
"set textwidth=120

"turn off preview menu for omni
set completeopt=menu

"Command-T configuration
let g:CommandTMaxHeight=10
let g:CommandTMatchWindowAtTop=1

"auto close preview window
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"automatically opens quickfix window on make errors
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow

"localvimrc
let g:localvimrc_sandbox=0
let g:localvimrc_ask = 0

map <F5> :call Compile()<CR>
map <F6> :make run<CR>

map <C-S-c> :A<cr>

"fix yaking conflict with ctrlp
let g:yankring_replace_n_pkey = '<Char-172>'
let g:yankring_replace_n_nkey = '<Char-174>'

"buffergator
let g:buffergator_viewport_split_policy="T"
let g:buffergator_split_size=15

"ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

"clang confs
let g:clang_use_library=1
let g:clang_snippets_engine="ultisnips"
let g:clang_complete_auto=1
let g:clang_user_options='-std=c++11'
let g:clang_auto_select=2
let g:clang_complete_copen=1

"treat std include files as cpp
au BufEnter /usr/include/c++/* setf cpp

"supertab confs
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<C-X><C-O>"

"usefull replacing macros
nnoremap gr gd[{V%:s/<C-R>///gc<left><left><left>
nnoremap gR gD:%s/<C-R>///gc<left><left><left>

"formatting style
autocmd BufNewFile,BufRead *.cpp set formatprg=astyle\ -A8s4SOclk1


if has("gui_running")
    "remove right scroll bar
    set guioptions-=r

    "remove menubar
    "set guioptions-=m

    "light colorscheme
    colorscheme light

    set guifont=Monospace\ 8
endif

" use :w!! to write to a file using sudo if you forgot to 'sudo vim file'
cmap w!! %!sudo tee > /dev/null %


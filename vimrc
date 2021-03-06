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
set showmatch

set number      "show line numbers

"display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set ttimeout
set ttimeoutlen=50

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
set shiftround
set softtabstop=4
set expandtab
set smarttab
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
set spelllang=en

"syntastic settings
"set updatetime=500 "parse after 500 ms of editing

"nerdtree settings
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 40


"source project specific config files
runtime! projects/**/*.vim

"dont load csapprox if we no gui support - silences an annoying warning
if !has("gui")
    let g:CSApprox_loaded = 1
endif


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

"make running commands less ugly
"set norestorescreen
set t_ti= t_te=

"get return codes from make
set shellpipe=2>&1\ \|\ tee\ %s;exit\ \${PIPESTATUS[0]}

"disable backup since most stuff are in git
set nobackup

"disable bells
set visualbell t_vb=

"more include paths for gf command
set path+=/usr/include/c++/4.7.2

"override make command for CMake projects
function! SetupMake()
    if filereadable("CMakeLists.txt") && filereadable("./build/Makefile")
        set makeprg=make\ -j8\ -C\ build
    else
        set makeprg=make\ -j8
    endif
endfunction

function! Compile()
    call SetupMake()
    make
endfunction

function! Run()
    call SetupMake()
    make run
endfunction

"command for bulding local tags
command! Ctags :!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q .
command! Vreload :source ~/.vimrc


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

"auto reload vimrc when saving
"autocmd BufWritePost .vimrc source ~/.vimrc

"localvimrc
let g:localvimrc_sandbox=0
let g:localvimrc_ask = 0


"fix yaking conflict with ctrlp
let g:yankring_replace_n_pkey = '<Char-172>'
let g:yankring_replace_n_nkey = '<Char-174>'

"buffergator
let g:buffergator_viewport_split_policy="T"
let g:buffergator_split_size=15
let g:buffergator_sort_regime="mru"

"ultisnips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

"YouCompleteMe
let g:ycm_confirm_extra_conf=0
nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR>

"ctrlp confs
let g:ctrlp_follow_symlinks=1

"easymotion
hi link EasyMotionTarget ErrorMsg
hi link EasyMotionShade  Comment

"gutter
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0
let g:gitgutter_sign_column_always = 1

"treat std include files as cpp
au BufEnter /usr/include/c++/* setf cpp

"formatting style
autocmd BufNewFile,BufRead *.cpp set formatprg=astyle\ -A1s4Sclk1
autocmd BufNewFile,BufRead *.h set formatprg=astyle\ -A2s4SOclk1

"auto remove trailing whitespaces
autocmd BufWritePre * :%s/\s\+$//e

if has("gui_running")
    "remove right scroll bar
    set guioptions-=r

    "turn off needless toolbar on gvim
    set guioptions-=T

    "remove menubar
    "set guioptions-=m

    "the lovely github theme.
    "colorscheme github
    "colorscheme Tomorrow-Night-Bright

    set guifont=Monospace\ 9
else
    "colorscheme Tomorrow-Night-Bright
endif

colorscheme koehler

"customize sign column
au BufEnter * highlight SignColumn ctermbg=black

" use :w!! to write to a file using sudo if you forgot to 'sudo vim file'
cmap w!! %!sudo tee > /dev/null %

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"useful replacing macros
nnoremap gr gd[{V%:s/<C-R>///gc<left><left><left>
nnoremap gR gD:%s/<C-R>///gc<left><left><left>

"explorer mappings
nnoremap <f1> :BuffergatorToggle<cr>
nnoremap <f2> :NERDTreeToggle<cr>
nnoremap <f3> :TagbarToggle<cr>
nnoremap <f4> :GundoToggle<cr>
map <f5> :call Compile()<CR>
map <f6> :call Run()<CR>

"fast vimrc editing
map <leader>v :e! ~/.vimrc<CR>

"allow switching windows while in insert mode
imap <C-w> <Esc><C-w>

"toggle spell checking
nmap <silent> <leader>s :set spell!<CR>

"key mapping for quickfix navigation
map <C-n> :cnext<CR>
"map <C-b> :cprevious<CR>
map <leader>q :ccl<cr>

map <C-s> :w<cr>

"clear highlight
nnoremap <C-L> :nohlsearch<cr>

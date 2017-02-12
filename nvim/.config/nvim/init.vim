"
" ~/.config/nvim/init.vim
"

" Automatic vim-plug installation
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')

" List of plugins
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-abolish'
Plug 'terryma/vim-multiple-cursors'
Plug 'terryma/vim-expand-region'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'scrooloose/nerdcommenter'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tmux-plugins/vim-tmux'
Plug 'reedes/vim-pencil'
Plug 'reedes/vim-wordy'
Plug 'reedes/vim-lexical'
Plug 'reedes/vim-litecorrect'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/sessionman.vim'
Plug 'vim-scripts/restore_view.vim'
Plug 'mhinz/vim-signify'
Plug 'mhinz/vim-startify'
Plug 'mattn/gist-vim'
Plug 'mattn/webapi-vim'
Plug 'honza/vim-snippets'
Plug 'bling/vim-bufferline'
Plug 'ervandew/supertab'
Plug 'majutsushi/tagbar'
Plug 'mbbill/undotree'
Plug 'jiangmiao/auto-pairs'
Plug 'godlygeek/tabular'
Plug 'morhetz/gruvbox'
Plug 'kien/ctrlp.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Initialize plugin system
call plug#end()

"" General

let mapleader = ","                                                 " Remap <leader>
set completeopt=menu,preview,longest                                " Insert mode completion
set hidden                                                          " Allow buffer switching without saving
set linebreak                                                       " Don't cut words on wrap
set list                                                            " Displaying listchars
set noshowmode                                                      " Hide mode cmd line
set noexrc                                                          " Don't use other .*rc(s)
set nostartofline                                                   " Keep cursor column pos
set nowrap                                                          " Do not wrap long lines
set splitbelow                                                      " Split windows to the bottom
set splitright                                                      " Split windows to the right
set ttyfast                                                         " For faster redraws etc
set foldcolumn=0                                                    " Hide folding column
set foldmethod=indent                                               " Folds using indent
set foldnestmax=10                                                  " Max 10 nested folds
set foldlevelstart=99                                               " Folds open by default
set gdefault                                                        " Default s//g (global)
set matchtime=2                                                     " Time to blink match {}
set matchpairs+=<:>                                                 " For ci< or ci>
set showmatch                                                       " Show matching brackets/parenthesis
set mat=2                                                           " Tenths of seconds to blink when matching brackets
set lazyredraw                                                      " Don't redraw while executing macros
set magic                                                           " For regular expressions turn magic on


" Wildmode/wildmenu command-line completion
set wildignore+=*.bak,*.swp,*.swo
set wildignore+=*.a,*.o,*.so,*.pyc,*.class
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.pdf
set wildignore+=*/.git*,*.tar,*.zip
set wildmenu
set wildmode=longest:full,list:full

"" Interface

" Colorscheme from plugin
if filereadable(expand("~/.local/share/nvim/plugged/gruvbox/colors/gruvbox.vim"))
    colorscheme gruvbox
endif

" Enable 256 colors to stop the CSApprox warning and make urxvt vim shine
if &term == 'urxvtc' || &term == 'tmux'
    set t_Co=256
endif

set background=dark                                                 " We're using a dark bg
set cursorline                                                      " Highlight cursor line
set number                                                          " Line numbers
set numberwidth=4                                                   " 9999 lines
set showcmd                                                         " Show cmds being typed
set title                                                           " Window title
set vb t_vb=                                                        " Disable beep and flashing

"" Files

set autochdir                                                       " Always use curr. dir.
set confirm                                                         " Confirm changed files
set noautowrite                                                     " Never autowrite
set nobackup                                                        " Disable backups
set undodir=$HOME/.local/share/nvim/undo/                           " Where to store undofiles
set undofile                                                        " Enable undofile
set undolevels=500                                                  " Max undos stored
set undoreload=10000                                                " Buffer stored undos
set directory^=$HOME/.local/share/nvim/swap/                        " Default cwd for swap
set swapfile                                                        " Enable swap files
set updatecount=50                                                  " Update swp after 50chars

"" Text

set expandtab                                                       " Use spaces instead of tabs
set shiftwidth=4                                                    " Default 8
set tabstop=4                                                       " Replace <TAB> w/4 spaces
set softtabstop=4                                                   " Tab feels like <tab>
set shiftround                                                      " Be clever with tabs
set ignorecase                                                      " Ignore case when searching
set smartcase                                                       " When searching try to be smart about cases

"" Keybindings

noremap <leader>ve :edit $HOME/.config/nvim/init.vim<cr>            " Edit init.vim
noremap <leader>vs :source $HOME/.config/nvim/init.vim<cr>          " Source init.vim
nnoremap Y y$                                                       " Yank(copy) to system clipboard
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<cr>    " Toggle folding
nnoremap gV '[V']                                                   " Highlight last inserted text
nmap <leader>w :w!<cr>                                              " Fast saving
"command W w !sudo tee % > /dev/null                                " :W sudo saves the file
map <space> /                                                       " <Space> to / (search)
map <c-space> ?                                                     " Ctrl-<Space> to ? (backwards search)
map <silent> <leader><cr> :noh<cr>                                  " Disable highlight when <leader><cr> is pressed
map <leader>q :e ~/buffer<cr>                                       " Quickly open a buffer for scribble
map <leader>x :e ~/buffer.md<cr>                                    " Quickly open a markdown buffer for scribble
map <leader>pp :setlocal paste!<cr>                                 " Toggle paste mode on and off
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/                  " Opens a new tab with the current buffer's path
map <leader>cd :cd %:p:h<cr>:pwd<cr>                                " Switch CWD to the directory of the open buffer
map 0 ^                                                             " Remap VIM 0 to first non-blank character

" Buffers, preferred over tabs now with bufferline.
nnoremap gn :bnext<cr>
nnoremap gp :bprevious<cr>
nnoremap gd :bdelete<cr>
nnoremap gf <C-^>

" Visual mode pressing # searches for the current selection
vnoremap <silent> # :<C-u>call VisualSelection('', '')<cr>?<C-R>=@/<cr><cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove 
map <leader>t<leader> :tabnext 

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<cr>
au TabLeave * let g:lasttab = tabpagenr()

"" Helper functions

" Don't close window, when deleting a buffer {
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction
" }

" Toggle syntax highlighting {
function! ToggleSyntaxHighlighthing()
    if exists("g:syntax_on")
        syntax off
    else
        syntax on
        call CustomHighlighting()
    endif
endfunction
nnoremap <leader>s :call ToggleSyntaxHighlighthing()<cr>
" }

" Toggle text wrapping, wrap on whole words {
function! WrapToggle()
    if &wrap
        set list
        set nowrap
    else
        set nolist
        set wrap
    endif
endfunction
nnoremap <leader>w :call WrapToggle()<cr>
" }

" Remove multiple empty lines {
function! DeleteMultipleEmptyLines()
    g/^\_$\n\_^$/d
endfunction
nnoremap <leader>ld :call DeleteMultipleEmptyLines()<cr>
" }

" Split to relative header/source {
function! SplitRelSrc()
    let s:fname = expand("%:t:r")

    if expand("%:e") == "h"
        set nosplitright
        exe "vsplit" fnameescape(s:fname . ".cpp")
        set splitright
    elseif expand("%:e") == "cpp"
        exe "vsplit" fnameescape(s:fname . ".h")
    endif
endfunction
nnoremap <leader>le :call SplitRelSrc()<cr>
" }

" Strip trailing whitespace, return to cursor at save {
function! StripTrailingWhitespace()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfunction

augroup StripTrailingWhitespace
    autocmd!
    autocmd FileType c,cpp,cfg,conf,css,html,perl,python,sh,tex,yaml
        \ autocmd BufWritePre <buffer> :call
        \ StripTrailingWhitespace()
augroup END
" }

"" Plugins

" Airline {
let g:airline_theme = 'gruvbox'
let g:airline_left_sep = ''
let g:airline_right_sep = ''
" }

" CtrlP {
let g:ctrlp_max_height = 20
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_reuse_window = 'startify'
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|exe|so|dll|pyc)$'
let g:ctrlp_map = '<c-f>'
map <leader>j :CtrlP<cr>
map <c-b> :CtrlPBuffer<cr>
" }

" NerdTree {
let g:NERDTreeWinPos = "right"
let g:NERDTreeWinSize = 35
let NERDTreeShowHidden = 0
let NERDTreeIgnore = ['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark
map <leader>nf :NERDTreeFind<cr>
" }

" Syntastic {
let g:syntastic_mode_map = {
    \ 'mode': 'passive',
    \ 'active_filetypes':
        \ ['c', 'cpp'] }
let g:syntastic_check_on_wq = 0
noremap <silent><leader>ll :SyntasticCheck<cr>
noremap <silent><leader>lo :Errors<cr>
noremap <silent><leader>lc :lclose<cr>
" }

" Pencil {
augroup pencil
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
                            \ | call lexical#init()
                            \ | call litecorrect#init()
augroup END
"}

" Session {
set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
nmap <leader>sl :SessionList<cr>
nmap <leader>ss :SessionSave<cr>
nmap <leader>sc :SessionClose<cr>
" }

" Snippet {
let g:neosnippet#snippets_directory='~/.local/share/nvim/plugged/vim-snippets/snippets'
" }

" SuperTab {
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabLongestEnhanced = 1
let g:SuperTabLongestHighlight = 1
" }

" TagBar {
set tags=tags;/
let g:tagbar_left = 0
let g:tagbar_width = 30
nnoremap <silent> <leader>tt :TagbarToggle<cr>
" }

" UndoTree {
let g:undotree_SetFocusWhenToggle=1
nnoremap <Leader>u :UndotreeToggle<cr>
" }

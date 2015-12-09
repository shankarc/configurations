set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents.  Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on

"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" One of the most important options to activate. Allows you to switch from an
" unsaved buffer without saving it first. Also allows you to keep an undo
" history for multiple files. Vim will complain if you try to quit without
" saving, and swap files will keep you safe if your computer crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window for multiple buffers, and/or:
" set confirm
" set autowriteall

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities.  As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline


"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell.  If visualbell is set, and
" this line is also included, vim will neither flash nor beep.  If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
" globals-cscope complains about this
"set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>


"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 2 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" two characters wide.
"set shiftwidth=2
"set tabstop=2


"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
noremap <C-L> :nohl<CR><C-L>

"------------------------------------------------------------
" fonts

"set guifont=Bitstream\ Vera\ Sans\ Mono\ 15
"set guifont=Courier\ 11

"ctags
map <F8> =!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q,<CR>
"macros

"font
"set guifont=courier_new:h15:w5:b
"The tag file
set tags=./tags;
",/home/Shankar/WindRiver/workspace/cmd_ard/cmd/tags
"6/7/2012 font
"set guifont=Times_New_Roman:h16:cANSI
"06/13/12
"This will hightlight a word under the cursor, jumps to split window brings it
"focus and bring the cursor back to the word
"c means check the word under cusror
"let @c="*�krn�kl"
let @c="*�krn�kl�kl"
"set cursorline
"set cursorcolumn
":highlight CursorColumn guibg=blue
"06/15/12
set dictionary=/usr/share/dict/words
";/home/Shankar/vimfiles/CMD_CMD.dict

"06/19/12
""set Tlist_Inc_Winwidth=0
"06/21/12
"incremental search
set incsearch
set hlsearch

" 09/20/12
"[merge]
"tool = vimdiff
"Then the command "git mergetool" will pick it up automatically. It's indeed a productivity booster!
"
"Also I'd recommend the peaksea color scheme for VIM to be used with vimdiff. With peaksea you don't have to worry about the diff color markup conflicting with the syntax highlighting itself -- when is the last time you opened two documents in diff mode only to find text "gone" because the syntax highlight color happens to be the same as diff background color? With peaksea I never had a problem.
"
"You can also configure VIM so that peaksea is only activated in diff mode. To do this, put someting like this in your ~/.vimrc:
"
"if &diff
"    set t_Co=256
"    set background=dark
"    colorscheme morning
"else
"    colorscheme YOUR_OTHER_COLOR_SCHEME_OF_CHOICE
"endif
"10/03/12
"enable the plugin
"filetype plugin on
"11/07/12
"
"To swap parameters in an equality statement
"to change if( a == 0)
"   to if(0 == a)
"
"noremap <C-S> :s/(\(.*\)\s\+==\s\(.*)\)/(\2 == \1)/<CR>:nohl<CR>
noremap <F2> :s/(\(.*\)\s\+==\s\(.*\))/(\2 == \1)/<CR>:nohl<CR>
"to change if( a != 0)
"   to if(0 != a)
noremap <F3> :s/(\(.*\)\s\+!=\s\(.*\))/(\2 != \1)/<CR>:nohl<CR>
"01/18/13
"No tabs in the source file.
"All tab characters are 4 space characters.
set tabstop=4
set shiftwidth=4
set expandtab
"5/22/13
" configure expanding of tabs for various file types
 au BufRead,BufNewFile *.py set expandtab
 au BufRead,BufNewFile *.c set noexpandtab
 au BufRead,BufNewFile *.h set noexpandtab
 au BufRead,BufNewFile Makefile* set noexpandtab
set syntax=cpp
" au BufRead,BufNewFile *.c set noexpandtab
" au BufRead,BufNewFile *.h set noexpandtab
" au BufRead,BufNewFile Makefile* set noexpandtab
"
" "
" --------------------------------------------------------------------------------
"  " configure editor with tabs and nice stuff...
"  "
"  --------------------------------------------------------------------------------
  set expandtab           " enter spaces when tab is pressed
"  set textwidth=120       " break lines when line length increases
  set tabstop=4           " use 4 spaces to represent tab
  set softtabstop=4
  set shiftwidth=4        " number of spaces to use for auto indent
  set autoindent          " copy indent from current line when starting a new line

" make backspaces more powerfull
  set backspace=indent,eol,start

set ruler                           " show line and column number
syntax on            " syntax highlighting
set showcmd          " show (partial) command in status line
"mkdir -p ~/.vim/autoload ~/.vim/bundle; \
"curl -Sso ~/.vim/autoload/pathogen.vim \
"    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
call  pathogen#infect()
"git submodule add -f git://github.com/rodjek/vim-puppet.git .vim/bundle/puppet
"03/21/14
" save readonly file
" sudo write
noremap sudow w !sudo tee % >/dev/null
"thrift syntax
au BufRead,BufNewFile *.thrift set filetype=thrift
au! Syntax thrift source ~/.vim/thrift.vim
set modeline
"08/07/14
:highlight DiffAdd ctermbg=Black
:highlight DiffChange ctermbg=Black
:highlight DiffDelete ctermbg=Black
:highlight DiffText cterm=Bold ctermbg=None
"save readonly file from vim
cnoremap sudow w !sudo tee % > /dev/null

:setlocal spell spelllang=en_us

" .vimrc
"
" This vimrc is divided into these sections:
"
" * Terminal Settings
" * User Interface
" * Text Formatting -- General
" * Text Formatting -- Specific File Formats
" * Search & Replace
" * Spelling
" * Keystrokes -- Moving Around
" * Keystrokes -- Formatting
" * Keystrokes -- Toggles
" * Keystrokes -- Insert Mode
" * Keystrokes -- For HTML Files
" * `SLRN' Behaviour
" * Functions Referred to Above
"
" This file contains no control codes and no `top bit set' characters above the
" normal Ascii range, and all lines contain a maximum of 79 characters.  With a
" bit of luck, this should make it resilient to being uploaded, downloaded,
" e-mailed, posted, encoded, decoded, transmitted by morse code, or whatever.


" first clear any existing autocommands:
autocmd!


" * Terminal Settings

" `XTerm', `RXVT', `Gnome Terminal', and `Konsole' all claim to be "xterm";
" `KVT' claims to be "xterm-color":
if &term =~ 'xterm'

 " `Gnome Terminal' fortunately sets $COLORTERM; it needs <BkSpc> and <Del>
 " fixing, and it has a bug which causes spurious "c"s to appear, which can be
 " fixed by unsetting t_RV:
 if $COLORTERM == 'gnome-terminal'
   execute 'set t_kb=' . nr2char(8)
   " [Char 8 is <Ctrl>+H.]
   fixdel
   set t_RV=

 " `XTerm', `Konsole', and `KVT' all also need <BkSpc> and <Del> fixing;
 " there's no easy way of distinguishing these terminals from other things
 " that claim to be "xterm", but `RXVT' sets $COLORTERM to "rxvt" and these
 " don't:
 elseif $COLORTERM == ''
   " Abhishek: following command screws up backspace deletes
   " execute 'set t_kb=' . nr2char(8)
   fixdel

 " The above won't work if an `XTerm' or `KVT' is started from within a `Gnome
 " Terminal' or an `RXVT': the $COLORTERM setting will propagate; it's always
 " OK with `Konsole' which explicitly sets $COLORTERM to "".

 endif
endif


" * User Interface

" have syntax highlighting in terminals which can display colours:
if has('syntax') && (&t_Co > 2)
 syntax on
endif

" have fifty lines of command-line (etc) history:
set history=50
" remember all of these between sessions, but only 10 search terms; also
" remember info for 10 files, but never any on removable disks, don't remember
" marks in files, don't rehighlight old search patterns, and only save up to
" 100 lines of registers; including @10 in there should restrict input buffer
" but it causes an error for me:
set viminfo=/10,'10,r/mnt/zip,r/mnt/floppy,f0,h,\"100

" have command-line completion <Tab> (for filenames, help topics, option names)
" first list the available options and complete the longest common part, then
" have further <Tab>s cycle through the possibilities:
set wildmode=list:longest,full

" use "[RO]" for "[readonly]" to save space in the message line:
set shortmess+=r

" display the current mode and partially-typed commands in the status line:
set showmode
set showcmd

" when using list, keep tabs at their full width and display `arrows':
execute 'set listchars+=tab:' . nr2char(187) . nr2char(183)
" (Character 187 is a right double-chevron, and 183 a mid-dot.)

" have the mouse enabled all the time:
"set mouse=a

" don't have files trying to override this .vimrc:
set nomodeline


" * Text Formatting -- General

" don't make it look like there are line breaks where there aren't:
set nowrap

" use indents of 2 spaces, and have them copied down lines:
set shiftwidth=2
"set shiftround
set expandtab
set autoindent

" normally don't automatically format `text' as it is typed, IE only do this
" with comments, at 79 characters:
set formatoptions-=t
set textwidth=77

" get rid of the default style of C comments, and define a style with two stars
" at the start of `middle' rows which (looks nicer and) avoids asterisks used
" for bullet lists being treated like C comments; then define a bullet list
" style for single stars (like already is for hyphens):
"set comments-=s1:/*,mb:*,ex:*/
"set comments+=s:/*,mb:**,ex:*/
"set comments+=fb:*

" treat lines starting with a quote mark as comments (for `Vim' files, such as
" this very one!), and colons as well so that reformatting usenet messages from
" `Tin' users works OK:
set comments+=b:\"
set comments+=n::


" * Text Formatting -- Specific File Formats

" enable filetype detection:
filetype on

" recognize anything in my .Postponed directory as a news article, and anything
" at all with a .txt extension as being human-language text [this clobbers the
" `help' filetype, but that doesn't seem to prevent help from working
" properly]:
augroup filetype
 autocmd BufNewFile,BufRead */.Postponed/* set filetype=mail
 autocmd BufNewFile,BufRead *.txt set filetype=human
augroup END

" in human-language files, automatically format everything at 72 chars:
autocmd FileType mail,human set formatoptions+=t textwidth=72

" for Perl programming, have things in braces indenting themselves:
autocmd FileType perl set smartindent

" for CSS, also have things in braces indented:
autocmd FileType css set smartindent

" for HTML, generally format text, but if a long line has been created leave it
" alone when editing:
autocmd FileType html set formatoptions+=tl

" for both CSS and HTML, use genuine tab characters for indentation, to make
" files a few bytes smaller:
autocmd FileType html,css set noexpandtab tabstop=4

autocmd FileType make,mk set noexpandtab tabstop=8

" * Search & Replace

" make searches case-insensitive, unless they contain upper-case letters:
set ignorecase
set smartcase

" show the `best match so far' as search strings are typed:
set incsearch

" assume the /g flag on :s substitutions to replace all matches in a line:
set gdefault


" * Spelling

" define `Ispell' language and personal dictionary, used in several places
" below:
let IspellLang = 'british'
let PersonalDict = '~/.ispell_' . IspellLang

" try to avoid misspelling words in the first place -- have the insert mode
" <Ctrl>+N/<Ctrl>+P keys perform completion on partially-typed words by
" checking the Linux word list and the personal `Ispell' dictionary; sort out
" case sensibly (so that words at starts of sentences can still be completed
" with words that are in the dictionary all in lower case):
execute 'set dictionary+=' . PersonalDict
set dictionary+=/usr/dict/words
set complete=.,w,k
set infercase

" correct my common typos without me even noticing them:
abbreviate teh the
abbreviate spolier spoiler
abbreviate Comny Conmy
abbreviate atmoic atomic

" Spell checking operations are defined next.  They are all set to normal mode
" keystrokes beginning \s but function keys are also mapped to the most common
" ones.  The functions referred to are defined at the end of this .vimrc.

" \si ("spelling interactive") saves the current file then spell checks it
" interactively through `Ispell' and reloads the corrected version:
execute 'nnoremap \si :w<CR>:!ispell -x -d ' . IspellLang . ' %<CR>:e<CR><CR>'

" \sl ("spelling list") lists all spelling mistakes in the current buffer,
" but excludes any in news/mail headers or in ("> ") quoted text:
execute 'nnoremap \sl :w ! grep -v "^>" <Bar> grep -E -v "^[[:alpha:]-]+: " ' .
 \ '<Bar> ispell -l -d ' . IspellLang . ' <Bar> sort <Bar> uniq<CR>'

" \sh ("spelling highlight") highlights (in red) all misspelt words in the
" current buffer, and also excluding the possessive forms of any valid words
" (EG "Lizzy's" won't be highlighted if "Lizzy" is in the dictionary); with
" mail and news messages it ignores headers and quoted text; for HTML it
" ignores tags and only checks words that will appear, and turns off other
" syntax highlighting to make the errors more apparent [function at end of
" file]:
nnoremap \sh :call HighlightSpellingErrors()<CR><CR>
nmap <F9> \sh

" \sc ("spelling clear") clears all highlighted misspellings; for HTML it
" restores regular syntax highlighting:
nnoremap \sc :if &ft == 'html' <Bar> sy on <Bar>
 \ else <Bar> :sy clear SpellError <Bar> endif<CR>
nmap <F10> \sc

" \sa ("spelling add") adds the word at the cursor position to the personal
" dictionary (but for possessives adds the base word, so that when the cursor
" is on "Ceri's" only "Ceri" gets added to the dictionary), and stops
" highlighting that word as an error (if appropriate) [function at end of
" file]:
nnoremap \sa :call AddWordToDictionary()<CR><CR>
nmap <F8> \sa


" * Keystrokes -- Moving Around

" have the h and l cursor keys wrap between lines (like <Space> and <BkSpc> do
" by default), and ~ covert case over line breaks; also have the cursor keys
" wrap in insert mode:
set whichwrap=h,l,~,[,]

" page down with <Space> (like in `Lynx', `Mutt', `Pine', `Netscape Navigator',
" `SLRN', `Less', and `More'); page up with - (like in `Lynx', `Mutt', `Pine'),
" or <BkSpc> (like in `Netscape Navigator'):
noremap <Space> <PageDown>
noremap <BS> <PageUp>
noremap - <PageUp>
" [<Space> by default is like l, <BkSpc> like h, and - like k.]

" scroll the window (but leaving the cursor in the same place) by a couple of
" lines up/down with <Ins>/<Del> (like in `Lynx'):
noremap <Ins> 2<C-Y>
noremap <Del> 2<C-E>
" [<Ins> by default is like i, and <Del> like x.]

" use <F6> to cycle through split windows (and <Shift>+<F6> to cycle backwards,
" where possible):
nnoremap <F6> <C-W>w
nnoremap <S-F6> <C-W>W

" use <Ctrl>+N/<Ctrl>+P to cycle through files:
nnoremap <C-N> :next<CR>
nnoremap <C-P> :prev<CR>
" [<Ctrl>+N by default is like j, and <Ctrl>+P like k.]

" have % bounce between angled brackets, as well as t'other kinds:
set matchpairs+=<:>

" have <F1> prompt for a help topic, rather than displaying the introduction
" page, and have it do this from any mode:
nnoremap <F1> :help<Space>
vmap <F1> <C-C><F1>
omap <F1> <C-C><F1>
map! <F1> <C-C><F1>


" * Keystrokes -- Formatting

" have Q reformat the current paragraph (or selected text if there is any):
nnoremap Q gqap
vnoremap Q gq

" have the usual indentation keystrokes still work in visual mode:
vnoremap <C-T> >
vnoremap <C-D> <LT>
vmap <Tab> <C-T>
vmap <S-Tab> <C-D>

" have Y behave analogously to D and C rather than to dd and cc (which is
" already done by yy):
noremap Y y$


" * Keystrokes -- Toggles

" Keystrokes to toggle options are defined here.  They are all set to normal
" mode keystrokes beginning \t but some function keys (which won't work in all
" terminals) are also mapped.

" have \tp ("toggle paste") toggle paste on/off and report the change, and
" where possible also have <F4> do this both in normal and insert mode:
nnoremap \tp :set invpaste paste?<CR>
nmap <F4> \tp
imap <F4> <C-O>\tp
set pastetoggle=<F4>

" have \tf ("toggle format") toggle the automatic insertion of line breaks
" during typing and report the change:
nnoremap \tf :if &fo =~ 't' <Bar> set fo-=t <Bar> else <Bar> set fo+=t <Bar>
 \ endif <Bar> set fo?<CR>
nmap <F3> \tf
imap <F3> <C-O>\tf

" have \tl ("toggle list") toggle list on/off and report the change:
nnoremap \tl :set invlist list?<CR>
nmap <F2> \tl

" have \th ("toggle highlight") toggle highlighting of search matches, and
" report the change:
nnoremap \th :set invhls hls?<CR>


" * Keystrokes -- Insert Mode

" allow <BkSpc> to delete line breaks, beyond the start of the current
" insertion, and over indentations:
set backspace=eol,start,indent

" have <Tab> (and <Shift>+<Tab> where it works) change the level of
" indentation:
"inoremap <Tab> <C-T>
"inoremap <S-Tab> <C-D>
" [<Ctrl>+V <Tab> still inserts an actual tab character.]

" abbreviations:
iabbrev lfpg Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch
iabbrev hse he/she
iabbrev sm Smylers


" * Keystrokes -- For HTML Files

" Some automatic HTML tag insertion operations are defined next.  They are
" allset to normal mode keystrokes beginning \h.  Insert mode function keys are
" also defined, for terminals where they work.  The functions referred to are
" defined at the end of this .vimrc.

" \hc ("HTML close") inserts the tag needed to close the current HTML construct
" [function at end of file]:
nnoremap \hc :call InsertCloseTag()<CR>
imap <F8> <Space><BS><Esc>\hca

" \hp ("HTML previous") copies the previous (non-closing) HTML tag in full,
" including attributes; repeating this straight away removes that tag and
" copies the one before it [function at end of file]:
nnoremap \hp :call RepeatTag(0)<CR>
imap <F9> <Space><BS><Esc>\hpa
" \hn ("HTML next") does the same thing, but copies the next tag; so \hp and
" \hn can be used to cycle backwards and forwards through the tags in the file
" (like <Ctrl>+P and <Ctrl>+N do for insert mode completion):
nnoremap \hn :call RepeatTag(1)<CR>
imap <F10> <Space><BS><Esc>\hna

" there are other key mappings that it's useful to have for typing HTML
" character codes, but that are definitely not wanted in other files (unlike
" the above, which won't do any harm), so only map these when entering an HTML
" file and unmap them on leaving it:
autocmd BufEnter * if &filetype == "html" | call MapHTMLKeys() | endif
function! MapHTMLKeys(...)
" sets up various insert mode key mappings suitable for typing HTML, and
" automatically removes them when switching to a non-HTML buffer

 " if no parameter, or a non-zero parameter, set up the mappings:
 if a:0 == 0 || a:1 != 0

   " require two backslashes to get one:
   inoremap \\ \

   " then use backslash followed by various symbols insert HTML characters:
   inoremap \& &amp;
   inoremap \< &lt;
   inoremap \> &gt;
   inoremap \. &middot;

   " em dash -- have \- always insert an em dash, and also have _ do it if
   " ever typed as a word on its own, but not in the middle of other words:
   inoremap \- &#8212;
   iabbrev _ &#8212;

   " hard space with <Ctrl>+Space, and \<Space> for when that doesn't work:
   "inoremap \<Space> &nbsp;
   "imap <C-Space> \<Space>

   " have the normal open and close single quote keys producing the character
   " codes that will produce nice curved quotes (and apostophes) on both Unix
   " and Windows:
   inoremap ` &#8216;
   inoremap ' &#8217;
   " then provide the original functionality with preceding backslashes:
   inoremap \` `
   inoremap \' '

   " curved double open and closed quotes (2 and " are the same key for me):
   inoremap \2 &#8220;
   inoremap \" &#8221;

   " when switching to a non-HTML buffer, automatically undo these mappings:
   autocmd! BufLeave * call MapHTMLKeys(0)

 " parameter of zero, so want to unmap everything:
 else
   iunmap \\
   iunmap \&
   iunmap \<
   iunmap \>
   iunmap \-
   iunabbrev _
   "iunmap \<Space>
   "iunmap <C-Space>
   iunmap `
   iunmap '
   iunmap \`
   iunmap \'
   iunmap \2
   iunmap \"

   " once done, get rid of the autocmd that called this:
   autocmd! BufLeave *

 endif " test for mapping/unmapping

endfunction " MapHTMLKeys()


" * `SLRN' Behaviour

" when using `SLRN' to compose a new news article without a signature, the
" cursor will be at the end of the file, the blank line after the header, so
" duplicate this line ready to start typing on; when composing a new article
" with a signature, `SLRN' includes an appropriate blank line but places the
" cursor on the following one, so move it up one line [if re-editing a
" partially-composed article, `SLRN' places the cursor on the top line, so
" neither of these will apply]:
autocmd VimEnter .article if line('.') == line('$') | yank | put |
 \ elseif line('.') != 1 | -

" when following up articles from people with long names and/or e-mail
" addresses, the `SLRN'-generated attribution line can have over 80 characters,
" which will then cause `SLRN' to complain when trying to post it(!), so if
" editing a followup for the first time, reformat the line (then put the cursor
" back):
autocmd VimEnter .followup if line('.') != 1 | normal gq${j


" set number
" Smaller text width to fit 4 code windows in vertically split mode.
set textwidth=77
set hlsearch
set wrap
set backspace=indent,eol,start
" My favorite colorscheme
colorscheme koehler
" Handy command for vertically splitting current buffe.
ab vsb vertical split buffer
" Default font is Monospace, which is fine, but shrink it slightly to fit 4
" vertical code windows in office.  On laptop this will fit two vertical code
" windows fully, and 3 with width=75
set guifont=Monospace\ 8
" Macro for switching to larger font, useful when working on laptop.
ab bigfont set guifont=Monospace\ 9
ab smallfont set guifont=Monospace\ 8
" Remove toolbar
set guioptions-=T
" Remove right scrollbar
set guioptions-=r
" Hide the buffer of old files as old buffers are closed or replaced by new
" files.  Otherwise, vim is unable to undo edits made to closed buffers.
set hidden
syn keyword cppNumber	nullptr

" Detect proto files
augroup filetype
  au! BufRead,BufNewFile *.proto setfiletype proto
augroup end

" Detect go files
augroup filetype
  au! BufRead,BufNewFile *.go setfiletype go
augroup end

" Abhishek: Disable error bell and visual bell
set noeb vb t_vb=

" Abhishek: Disable the irritating left-indent on typing :"
set indentkeys-=:

" Scons files are python files
augroup filetype
  au! BufRead,BufNewFile SConstruct setfiletype python
augroup end

augroup filetype
  au! BufRead,BufNewFile SConscript setfiletype python
augroup end

" Easy commands
command! FontSmall set guifont=Monospace\ 8
command! FontLaptop set guifont=Monospace\ 11
command! FontMedium set guifont=Monospace\ 14
command! FontBig set guifont=Monospace\ 18
command! LongLine set textwidth=10000000
command! Line set textwidth=80
command! Line100 set textwidth=100

" C++11 changes
syntax keyword Keword override

" clang-format
map <C-K> :pyf /home/abhishek/bin/clang-format.py<CR>
imap <C-K> <ESC>:pyf /home/abhishek/bin/clang-format.py<CR>i

" Bash like tab-completion for files.
set wildmode=longest,list,full

" Split window navigation.
noremap , <C-w><C-h>
noremap . <C-w><C-w>

" Detect .md files as markdown (by default they are detected as modula)
augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

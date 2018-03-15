# VIM
<!-- Thursday, June 13, 2013 6:10 PM L&M -->

####Links
[productivity - What is your most productive shortcut with Vim? - Stack Overflow](http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim?rq=1)

#### Save macro

Use q followed by a letter to record a macro. This just goes into one of the copy/paste registers so you can paste it as normal with the ["x]p or ["x]P commands in normal mode.

To save it you open up .vimrc and paste the contents, then the register will be around the next time you start vim. The format is something like:

let @q = 'macro contents'

Be careful of quotes, though. They would have to be escaped properly.

```
So to save a macro you can do:
From normal mode: qq
Enter whatever commands
From normal mode: q
open .vimrc
"qp to insert the macro into your "let @q = '...'" line
```
<!-- 16September2015 -->
######macro as a command in range
`a,b:normal @macro_buffer_name`


####Abbreviations

```
:iab \<expr\> dts strftime("%c")
:iab \<expr\> ddate strftime("%m/%d/%y")
```
```
:set list, nolist 
:set incsearch  -- Start searching when you type the first character
:set hlsearch  -- Search highlights the string matched by the search
```

#### Split Screen

```
 :sp filename             // Split horizontally with filename
 :vsp filename            // Split vertically with file filename
 :split                   // Splits horizontally
 :vs or ctrl-W ctrl-V     // Split vertically
 ctrl-w arrows_keys       // To switch between windows

```
#### Movements
~~~
 {     paragraph begin
 }      para end
 '' (two single quotes) to return back form ]] etc 
 :set cursorline\
 :set cursorcolumn\
 ctrl-W r or ctrl-W ctrl-r down/right R for up/left ctrl-W x or ctrl-W
ctrl-X to exchange\
 crtl-r ctrl-w\
 ctrl-wq\
 :ptag tag\<tab\> expands\
 :ptselect
~~~

######Using ctags
```
ctags -R

:cw 
:copen

:grep\
 :vimgrep\
 //location :lw :lopen :lgrep\
 :lvimgrep

:vimgrep take\_ilap\_packet cmd/src/\*.cpp


:vimgrep take\_ilap\_packet cmd/src/\*.cpp

:ts take\_ilap\_packet\
 provides the list which you can jump

:tn next tag\
 vim allows you to quickly switch between related source code files
```
<!-- 8/16/2012 -->
###### catonmat
~~~
 :e %\<.h\  loads the corresponding header file
 :sp %\<.h\	split
 :vsp %\<.h\	vertical split
 ----------\
 :e file\
 will switch to another file, and\
 :e\# bring back

----------\
 %:r is replaced with the currently edited filename minus the extension,
so you can use :e %:r.h and :e %:r.c to switch quickly

(use :tabe instead of :e to edit in a new tab). ver 7.0 and \> use :tabe
to use tabs
~~~

<!-- 9/27/2012 -->

#### Dark corners of vim
[what-are-the-dark-corners-of-vim-your-mom-never-told-you-about](http://stackoverflow.com/questions/726894/what-are-the-dark-corners-of-vim-your-mom-never-told-you-about)

```
:earlier 15m
:later
```

use full is g+ and g- to go backward and forward in time. This is so
much more powerful than an undo/redo stack

since you don't loose the history when you do something after an undo

```
 diw to delete the current word
 di( to delete within the current parens
 di" to delete the text between the quotes Others can be found on :help
text-objects
 its equivalent "change" commands:
 ciw , ci( , ci" , as well as dt\<space\> and ct\<space\>
```
```
:%!xxd
 Make vim into a hex editor. :%!xxd -r
```
####Comment blocks of code, Justify start of lines etc.

```
Select block with CTRL-V.

Hit I (capital I) and enter your comment string at the beginning of the line. (// for C++) Hit ESC and all lines selected will have prepended to the front of the line. You can use A for appending all the lines.
```
:g/rgba/y A\
 will yank all lines containing "rgba" into the a buffer.

I used it a lot recently when making Internet Explorer stylesheets
Sometimes a setting in your .vimrc will get overridden by a plugin or autocommand. To debug this a useful trick is to use the :verbose command in conjunction

with :set. For example, to figure out where cindent got set/unset:
:verbose set cindent?

I can apply that "macro" to a file by using a command like: vim +'so
mymacro.ex' file


<!-- 11/07/12 -->
#### Flip code

[vim - Swap text around equal sign - Stack Overflow](http://stackoverflow.com/questions/1374105/swap-text-around-equal-sign)

Is there an easy way to flip code around an equal sign in vi/vim\
 I want to turn this:

```value._1 = return_val.delta_clear_flags;```

into

```return_val.delta_clear_flags = value._1;```

```
:%s/\([^=]*\)\s\+=\s\+\([^;]*\)/\2 = \1
```
```
:%s:\([^=]*\)\s\+=\s\+\([^;]*\):\2 = \1
```

 You might have to fiddle with it a bit if you have more complex code
than what you have shown in the example.

EDIT: Explanation

We use the s/find/replace command. The find part gets us this:

* longest possible string consisting of non-equal-signs, expressed
 by [^=]* 
*  followed by a space or more, \s\+ (the extra \ in front of +
is a vim oddity)\
*  followed by = and another space or more, =\s\+
*  followed by the longest possible string of non-semicolon
characters, [\^;]
 
 Then we throw in a couple of capturing parentheses to save the stuff
we'll need to construct the replacement string, that's the \(stuff\)
syntax

And finally, we use the captured strings in the replace part of the
s/find/replace command: that's \\1 and \\2.

http://vim.wikia.com/wiki/Swap\_LHS\_and\_RHS\_of\_an\_Assignment\_statement?printable=yes

Suppose you have a statement (C/C++/Java/etc):

alpha = beta;\
 and you want to change it to:

beta = alpha;\
 Try this mapping:

noremap \<C-S\> :s/\\([\^ =]\*\\)\\([ ]\*\\)=[ ]\*\\([\^;]\*\\);/\\3 =
\\1;/\<CR\>:nohl\<CR\>\
 \<C-S\> may cause Unix terminals to suspend. Replace with \<F2\> or
something easy to remember for your own purposes.

This mucks with your current matched highlighting selections; thus the
trailing `:nohl`. If someone knows how to do this without mucking with the
incremental searches jot it down.\
 If you don't want Vim to mangle formatting in incoming pasted text, you
might also want to consider using: `:set paste` This will prevent vim from
re-tabbing your code.

It's also possible to toggle the mode with a single key, by adding
something like set pastetoggle=\<F2\> to your .vimrc. More details on
toggling auto-indent here.

#### How do i turn off the :set paste?
 ~~~
 :set nopaste
 ~~~
 will disable paste mode
 For the record, if you prepend no to any almost any setting it'll
disable it: `:set noexpandtab` and `:set expandtab` are opposite of each
other. A better way is :set paste! Probably set paste is very close in
your command history, so you can simply press ':', then arrow-up and add
a '!'.

<!-- 6/7/13 -->

### To convert lines like this in multiple Files
```
#include "cmd_Command_Stack_Executor.h"
#include "mess_buffer.h"
#include "message_que.h"
#include "cmd_Execution_Queue.h"
```
to lines like this:

```
#include <cmd_Command_Stack_Executor.h>
#include <mess_buffer.h>
#include <message_que.h>
#include <cmd_Execution_Queue.h>

```
Load all the source and header files
 `vim src/*.cpp include/*.h`
 
 execute these two commands
 (Two are need because the first " will be substituted with \< and the
second will be substituted " with \> ) 

`:argdo %g/\#include/s/"/\</e |`

update

`:argdo %g/\#include/s/"/\>/e | update argdo` - apply for all the
arguments.

Where:\
 % - for all the lines.\
 g - global command select a set of lines by a regular expression (here
it is \#include) and feed it to vi command here its s(substitute). s -
substitute command.\
 e - no error if the pattern is not found.\
 | - separator between commands.\
 update - save if the changes were made

Note:

s/"/\</e | s/"/\>/e works so the above two ex commands can be a single
command :argdo %g/\#include/s/"/\</e | s/"/\>/e | update\
 To know more about substitution flags\
 :help :s\_flags

:argdo! %s:wxlogmessage://wxlogmessage:e

<!-- 06/14/13 -->

 " convert all function calls bar(thing) into method calls thing.bar()
"\
 g/bar(/ normal nmaf(ldi(\`aPa.\
 explanation:\
 g/bar(/ executes the following command on every line that contains
"bar(" normal execute the following text as if it was typed in in normal
mode

n ma f(\
 l di( \`a P a.

goes to the next match of "bar(" (since the :g command leaves the cursor
position at the start of the line) saves the cursor position in mark a

moves forward to the next opening bracket\
 moves right one character, so the cursor is now inside the brackets

delete all the text inside the brackets\
 go back to the position saved as mark a (i.e. the first character of
"bar") paste the deleted text before the current cursor position\
 go into insert mode and add a "."

q: in normal mode lists previous command

<!-- 07/15/13 -->
 * di( -- delete inside ()
 * di{ -- delete inside {}
 * di[ -- delete inside []
 * di" -- delete inside ""

####  How to insert current file name
<!-- 08/12/13 -->
 Register % contains the name of the current file, and register #
contains the name of the alternate file. These registers allow the name
of the current or alternate files to be displayed or inserted

<!-- 09/16/13 -->
####  The idea is to remove a block of code

For example, to delete everything between two matches, excluding the
matching lines, execute

`:/first regex/+1;/second regex/-1d`

This will only delete next block. If you want to delete all block,
prefix the command with "g":

`:g/first regex/+1;/second regex/-1d`


`:g/first regex/+1;/second regex/-1d`

status = copy\_PIL\_from\_shared\_memory\_to\_dlrt\_buffer(pi\_type,
start\_time,

dlrt\_buffer, length\_copied);

\#ifdef REMOVE\_ME\_AFTER\_TESTING //---------- REMOVE ME AFTER TESTING
printf("hex\_dump of dlrt\_buffer\\n"); hex\_dump(dlrt\_buffer,
length\_copied); //----------

\#endif\
 download\_size += length\_copied;

dlrt\_buffer += length\_copied; }

:g/REMOVE/;/\#endif/d\
 to do it on all cpp files\
 :argo g/REMOVE/;/\#endif/p to print it later use d

<!-- 09/19/13 -->

#### Edit the last modified file.

I used this when I change some things on\
 IDE and need power of VIM to complete it.\
 [Shankar]\$ /bin/ls -rt |tail -1\
 cmd\_Configuration\_File.h\
 [Shankar]\$ /bin/ls -rt |tail -1 | xargs bash -c
'\</dev/tty vim "\$@"' ignoreme

xargs points stdin to /dev/null From OSX/BSD man xargs

-o Reopen stdin as /dev/tty in the child process before executing the
command. This is useful\
 if you want xargs to run an interactive application.

Thus the following line of code should work for you:

find . -name "\*.txt" | xargs -o vim
--------------------------------------------------------------------------------

For GNU man xargs there is no flag, but we can explicitly pass in
/dev/tty to solve the problem:

find . -name "\*.txt" | xargs bash -c '\</dev/tty vim "\$@"' ignoreme\
 the ignoreme is there to take up \$0, so that \$@ is all arguments from
xargs
--------------------------------------------------------------------------------\
 Even this works\
 /bin/ls because I have alias for ls

vim \$(/bin/ls -rt |tail -1)

Problem:\
 // Input: logging\_level: The log level for logging to occur

I have to change second' :' to - look like this\
 // Input: logging\_level - The log level for logging to occur

:s/.\*\\zs:/ -/\
 The easiest way would be to allow arbitrary text in front of the match,
and specify the matched region using \\zs:

s/\\\<./\\u&/g\
 \\\< matches the start of a word\
 . matches the first character of a word\
 \\u tells Vim to uppercase the following character in the substitution
string (&) & means substitute whatever was matched on the LHS

#### To turn one line into title caps, make every first letter of a word
uppercase: \>

`:s/\\v\<(.)(\\w\*)/\\u\\1\\L\\2/g`


`:s/\\v\<(.)(\\w\*)/\\u\\1\\L\\2/g`

<!-- 9/20/13 -->

#### To stop/quit unresponsive vim

1016 ps -a \<-get the pid\
 1017 man kill\
 1018 kill -l \< to get the list of signal 1021 kill -s SIGQUIT 11323

Vim: Caught deadly signal QUIT Vim: preserving files ...\
 Vim: Finished.\
 Quit

Remove the .swp file

To convert // Input:

// pv\_object: The PV object identifier Into i.e to join

// Input: // pv\_object: The PV object identifier\
 :g/Input:\\s\*\$/j\
 Find Input:and nothing else (i.e space) on the line and execute join

To do


     :340,358s/.\*\\/\\/\\s\*\\zs/ /\
     explantion:\
     \<range\> match \<and number of char\>//\<space\>one or more\<end
    region mark\> substitute with 8 spaces to align \
     :340,358s /.\* \\/\\/ \\s\* \\zs / / alternate \
     340,358s:.\*//\\s\*\\zs: : \
     09/23/13 \
     http://vimdoc.sourceforge.net/htmldoc/pattern.html

|/\\zs| \\zs \\zs anything, sets start of match |/\\ze| \\ze \\ze
anything, sets end of match


### To overwrite the line you are copying
<!-- 09/26/13 my -->

419 ////////////////////////////////////////////
427 //-------------------------------------------
 To change line 419 as of 427


To change line 419 as of 427\
 :427t419|+d\
 copy line 427 to line 419 and then execute separate command (|) move to
next line and delete it

<!-- 09/30/13 -->

### To delete up to character

Use 'df' c.\
 If you had:\
 delete until exclamation point!\
 And the cursor was at the first space and you typed df!, you would
get:\
 delete\
 Also 'dtc'. This will delete up to but not including c. Using dt! on
the same example above would give you: delete!\
 Just about any "motion" can be used for the d, c, y and similar
commands

<!-- 10/02/13 -->

### Saving the result of regexp search to a file

:g/cmd\_Command\_Manager/ .w \>\> junk Note: junk should exist

<!-- 10/15/13 -->

 \#include \<cmd\_Big\_Parameter\_manager.h\>\
 to\
 /\*vcast\_dont\_instrument\_start\*\
 command\
 :/\#include/normal O /\*vcast\_dont\_instrument\_start\*/

You can also use this command: :g/\^\#/norm O\
 This is a shortcut of :global/\^\#/normal O which means:

for each line starting with '\#' (:global/\^\#/)\
 do 'O' command in 'normal mode' (normal O)\
 which means to do what a 'O' key does in the 'normal' (not insert and
not :command) VIM mode. And 'O' inserts a new line

To add an empty line after a }\
 :%s/}/\\0\\r/gReplace } with the whole match \\0 and a new line
character \\r. or

:%s/}/&\\r/gWhere & also is an alternative for the whole match

An easy way to find the last occurrence is to jump to the end and search
backwards: G?foo\<CR\>

Find the last occurrence of a string and substitute

:?\#include?s/cmd\_/rom\_/:

<!-- 10/17/13 -->
 Command to exclude header file from vectorCAST instrumentation.\
 Before running vectorCAST / COVER you need to tell vector CAST no
instrument certain headers .\
 These two command will wrap the header files with
/\*vcast\_dont\_instrument\_start\*/ /\*vcast\_dont\_instrument\_end\*/

[Shankar]\$ for f in \`/bin/ls include/\*.h src/\*.cpp\`; do vim
-c":/\#include/normal O /\*vcast\_dont\_instrument\_start\*/" -c":wq"
\$f; done [Shankar]\$ for f in \`/bin/ls include/\*.h src/\*.cpp\`; do
vim -c":?\#include?normal o /\*vcast\_dont\_instrument\_end\*/" -c":wq"
\$f; done

Converts this\
 \#include "cmd\_globals.h"\
 \#include "cmd\_Command\_Stack\_List.h" \#include "cmd\_Payload.h"\
 \#include "cmd\_Command\_Parser.h"

into this

/\*vcast\_dont\_instrument\_start\*/ \#include "cmd\_globals.h"


\#include "cmd\_globals.h"\
 \#include "cmd\_Command\_Stack\_List.h" \#include "cmd\_Payload.h"\
 \#include "cmd\_Command\_Parser.h" /\*vcast\_dont\_instrument\_end\*/

Then you can rearrange them manually to exclude the headers not to be
instrumented

Thanks Shankar

Vim \*.cpp or \*.h

:argdo!:/\#include/normal O /\*vcast\_dont\_instrument\_start\*/
:argdo!:?\#include?normal o /\*vcast\_dont\_instrument\_end\*/ :wq It
ask to save select A(ll)

<!-- 10/29/13 -->

#### Undo / Redo

Also check out :undolist, which offers multiple paths through the undo
history. This is useful if you accidentally type something after undoing
too much\
 take the number from :undolist and type :undo 178 (say) to rewind to
step 178.\
 Pasted from
\<http://stackoverflow.com/questions/1555779/how-do-i-do-redo-i-e-undo-undo-in-vim\>

:%s/CMD/ROM/gn\
 Will not substitute, tells the number of lines matches. Highlights
matches

#### calculations
In the insertion mode
Ctrl-r=5*6<enter> // inserts the answer

#### vimdiff


do //get from other
dp // put to other
]c // next change
[c // previous change
ctrl-w ctrl-w switch panes

Also
:diff this if you use :vs or :sp
:diffoff

#### To html
:ToHtml
:w

#### Using sed
:r !sed -n '29,53p' file.txt

:enew

:R ! awk 'BEGIN{ for (i=0; i< 91 ; i++) printf "0x%x," 0xF0000000 +i }'

#### python
A useful addition to Python source files is this comment:

`vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4`

#### Multiple files
:argdo
:bufdo
:bufdo %s/pattern/replace/gc /update

#### fold
```
:help fold-methods
zi folding on/off
{
zj  <-move 
zk  <-move
}   vkkk or vjjj
za //togle cuurent fold
zc //close fold
zM //Closes all
zV reveal cursor
zR open all fold
```
For python
`:set foldmethod=indext`

####  Copy a line from another split window
<!-- Aug 8,2014 -->
You can use sed

`:206 r !sed -n 13,15p extract_info.py`

#### Highlight non-ASCII char
```
Using range in a [] character class in the search
/[^\x00-\x7F]
This will do a negative match (via [^]) for characters between ASCII 00 and ASCII 7F (0-127),
```

####MacVIM
* [How to use a vim color](http://alvinalexander.com/linux/vi-vim-editor-color-scheme-colorscheme)
* [Switch color schemes - Vim Tips Wiki](http://vim.wikia.com/wiki/Switch_color_schemes)
* [10 vim color schemes you need to own ](http://www.vimninjas.com/2012/08/26/10-vim-color-schemes-you-need-to-own/)
* [gruvbox Wiki · GitHub](https://github.com/morhetz/gruvbox/wiki/Installation)

######colorscheme

    :colorscheme macvim
    :set bg=dark
    :color desert // slate is also good

You can see the available color schemes in vim's colors folder, for example in my case:

~~~
$ ls /usr/share/vim/vimNN/colors/ 
# where vimNN is vim version, e.g. vim74
blue.vim  darkblue.vim  default.vim  delek.vim  desert.vim  elflord.vim 
evening.vim  koehler.vim  morning.vim  murphy.vim  pablo.vim  peachpuff.vim
README.txt  ron.vim  shine.vim  slate.vim  torte.vim  zellner.vim
~~~

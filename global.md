## Using Gnu Global with excuberant ctags

   	brew install global --with-exuberant-ctags

### Copy global config file
    cp /usr/local/etc/gtags.conf ~/.globalrc
###  Tell globals to use ctags
    export GTAGSLABEL=ctags


     
## Add new language
   
### Add .thrift 

Make Ctags understand thrift
```
:~ $ cat ~/.ctags
--langdef=thrift
--langmap=thrift:.thrift
--regex-thrift=/^[ \t]*struct[ \t]*([a-zA-Z0-9_]+)/\1/c,classes/
--regex-thrift=/^[ \t]*enum[ \t]*([a-zA-Z0-9_]+)/\1/T,types/
--regex-thrift=/^[ \t]*[a-zA-Z0-9_<>\.]+[ \t]*([a-zA-Z0-9_]+)\(/\1/m,methods/
--regex-thrift=/^[ \t]*([A-Z0-9_]+)[ \t]*=/\1/C,constants/

```

Make globals use it

```
:~ $ diff  /usr/local/etc/gtags.conf ~/.globalrc
98a99
> 	:langmap=THRIFT\:.thrift:\
137c138,139
< 	:gtags_parser=YACC\:/usr/local/Cellar/global/6.2.12/lib/gtags/exuberant-ctags.la:
---
> 	:gtags_parser=YACC\:/usr/local/Cellar/global/6.2.12/lib/gtags/exuberant-ctags.la:\
> 	:gtags_parser=THRIFT\:/usr/local/Cellar/global/6.2.12/lib/gtags/exuberant-ctags.la:

```

## Create a HTML dir of your source

### Generate tags
        gtags -v
### Generate HTML for source
        htags
        htags --line-number
        htags --suggest
### Open in browser
        cd HTML/
        open index.html 
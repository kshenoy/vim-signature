# vim-signature
vim-signature is a plugin to toggle, display and navigate marks.  

Wait a minute...isn't this done excellently by vim-showmarks and mark-tools; why another plugin you say?  
Well, you are right. However, I got a little impatient with the delay between setting and display of marks in vim-showmarks and  
I liked the navigation options which mark-tools provided and I didn't want to use two plugins where one would do and  
I was bored and felt like writing my own... Are you convinced yet or do you want me to go on?  

Anyway, that's how vim-signature was born.

## Requirements
Requires Vim to be compiled with +signs to display marks.

## Installation
I highly recommend using Pathogen or Vundler to do the dirty work for you. If
for some reason, you do not want to use any of these excellent plugins, then
unzip it to your ~/.vim directory. You know how it goes...  

So, once that's done, out of the box, the followings mappings are defined
`mx` to place the mark `x` where x can be a-z, A-Z. x can also take values
from 0-9. However, instead of the number, `)!@#$%^&*(` will be displayed as a
sign. The following mappings are set by default.  
```
nmap '] <Plug>SIG_NextLineByAlpha    # Jump to next mark  
nmap '[ <Plug>SIG_PrevLineByAlpha    # Jump to prev mark  
nmap `] <Plug>SIG_NextSpotByAlpha    # Jump to next mark by Alphabetical Order  
nmap `[ <Plug>SIG_PrevSpotByAlpha    # Jump to prev mark by Alphabetical Order  
nmap ]' <Plug>SIG_NextLineByPos      # Jump to beginning of next line containing a mark  
nmap [' <Plug>SIG_PrevLineByPos      # Jump to beginning of prev line containing a mark  
nmap ]` <Plug>SIG_NextSpotByPos      # Jump to next line by Alphabetical Order  
nmap [` <Plug>SIG_PrevSpotByPos      # Jump to next prev by Alphabetical Order  
nmap ]= <Plug>SIG_NextMarkerByType   # Jump to next line having same marker  
nmap ]- <Plug>SIG_PrevMarkerByType   # Jump to prev line having same marker  
```
This will allow the use of default behavior of m to set marks and, if the line
already contains the mark, it'll be unset.  
The default behavior of `]'`, `['`, ]_`_ and [_`_ is supported and enhanced by
wrapping around when beginning or end of file is reached.  
  
## Customisation
However, if the defaults are not to your liking, use the following  

`g:SignatureDefaultMappings` ( Default : 1 )  
Will use the default mappings specified below.  

`g:SignatureIncludeMarks` ( Default : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' )  
Specify the marks that can be controlled by this plugin.  
Only supports Alphabetical marks at the moment.  

`g:SignatureWrapJumps` ( Default : 1 )
Specify if jumping to marks should wrap-around.  

`g:SignatureLeader` ( Default: m )  
Set the key used to Toggle Marks.  If this key is set to `<leader>m`  
`<leader>ma` will toggle the mark 'a'  
`<leader>m,` will place the next available mark  
`<leader>m<Space>` will delete all marks  

<Plug>SIG_NextLineByAlpha  : Jump to next mark  
<Plug>SIG_PrevLineByAlpha  : Jump to prev mark  
<Plug>SIG_NextSpotByAlpha  : Jump to next mark by Alphabetical Order  
<Plug>SIG_PrevSpotByAlpha  : Jump to prev mark by Alphabetical Order  
<Plug>SIG_NextLineByPos    : Jump to beginning of next line containing a mark  
<Plug>SIG_PrevLineByPos    : Jump to beginning of prev line containing a mark  
<Plug>SIG_NextSpotByPos    : Jump to next line by Alphabetical Order  
<Plug>SIG_PrevSpotByPos    : Jump to next prev by Alphabetical Order  
<Plug>SIG_NextMarkerByType : Jump to next line having same marker  
<Plug>SIG_PrevMarkerByType : Jump to prev line having same marker  

## Thanks to...
* Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
* Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)  

I feel obligated to mention that as some portions were coded so well by them, I could think of no way to improve them and I've just used it as is.
Well, you know what they say... _"Good coders use; great coders reuse"_ ;)

## ToDo:
* Add custom color support for signs
* Add custom character display support for signs
* Add support for non-Alphabetical marks

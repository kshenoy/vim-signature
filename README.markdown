# vim-signature
vim-signature is a plugin to toggle, display and navigate marks.  

Wait a minute...isn't this done excellently by vim-showmarks and mark-tools; why another plugin you say?  
Well, you are right. However, I got a little impatient with the delay between setting and display of marks in vim-showmarks and  
I liked the navigation options which mark-tools provided and I didn't want to use two plugins where one would do and  
I was bored and felt like writing my own... Are you convinced yet or do you want me to go on?  

Anyway, that's how vim-signature was born and it does the following    

`<SignatureLeader>[a-zA-Z]`  : Place alphabetical marks (normal behavior)  
`<SignatureLeader>[0-9]`     : Place  )!@#$%^&_*_( as signs  
`<Plug>Sig_NextSpotByPos`    : Jump to next mark  
`<Plug>Sig_PrevSpotByPos`    : Jump to prev mark  
`<Plug>Sig_NextSpotByAlpha`  : Jump to next mark by Alphabetical Order  
`<Plug>Sig_PrevSpotByAlpha`  : Jump to prev mark by Alphabetical Order  
`<Plug>Sig_NextLineByPos`    : Jump to beginning of next line containing a mark  
`<Plug>Sig_PrevLineByPos`    : Jump to beginning of prev line containing a mark  
`<Plug>Sig_NextLineByAlpha`  : Jump to next line by Alphabetical Order  
`<Plug>Sig_PrevLineByAlpha`  : Jump to next prev by Alphabetical Order  
`<Plug>Sig_NextMarkerByType` : Jump to next line having same marker  
`<Plug>Sig_PrevMarkerByType` : Jump to prev line having same marker  

## Requirements
Requires Vim to be compiled with +signs to display marks.

## Customisation
`g:SignatureDefaultMappings` : Will use the default mappings specified below.  
Default: 1

`g:SignatureIncludeMarks` : Specify the marks that can be controlled by this plugin.  
Default: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'  
Only supports Alphabetical marks at the moment.  

`g:SignatureWrapJumps` : Specify if jumping to marks should wrap-around.  
Default: 1

`g:SignatureLeader` : Set the key used to Toggle Marks.  
Default: m  
  
If this key is set to `<leader>m`  
`<leader>ma` will toggle the mark 'a'  
`<leader>m,` will place the next available mark  
`<leader>m<Space>` will delete all marks  
 

## Default Mappings
```
nmap '] <Plug>SIG_NextLineByAlpha
nmap '[ <Plug>SIG_PrevLineByAlpha
nmap `] <Plug>SIG_NextSpotByAlpha
nmap `[ <Plug>SIG_PrevSpotByAlpha
nmap ]' <Plug>SIG_NextLineByPos
nmap [' <Plug>SIG_PrevLineByPos
nmap ]` <Plug>SIG_NextSpotByPos
nmap [` <Plug>SIG_PrevSpotByPos
nmap ]= <Plug>SIG_NextMarkerByType
nmap ]- <Plug>SIG_PrevMarkerByType
```
This will allow the use of default behavior of m to set marks and, if the line already contains the mark, it'll be unset.  
Default behavior of `]'`, `['`, ]_`_ and [_`_ enhanced by wrapped jumps.  
To disable the default mappings and use custom mappings, set
    let g:SignatureDefaultMappings = 0

## Thanks to...
* Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
* Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)  

I feel obligated to mention that as some portions were coded so well by them, I could think of no way to improve them and I've just used it as is.
Well, you know what they say... _"Good coders use; great coders reuse"_ ;)

## ToDo:
* Add custom color support for signs
* Add custom character display support for signs
* Add support for non-Alphabetical marks

# vim-mark_my_words
vim-mark_my_words is a plugin to toggle, display and navigate marks.  

Wait a minute...isn't this done excellently by vim-showmarks and mark-tools; why another plugin you say?  
Well, you are right. However, I got a little impatient with the delay between setting and display of marks in vim-showmarks and  
I liked the navigation options which mark-tools provided and I didn't want to use two plugins where one would do and  
I was bored and felt like writing my own... Are you convinced yet or do you want me to go on?  

Anyway, that's how vim-mark_my_words was born.    

## Requirements
Requires Vim to be compiled with +signs to display marks.

## Customisation
`g:MarkMyWords_DefaultMappings` : Will use the default mappings specified below.  
Default: 1

`g:MarkMyWords_IncludeMarks` : Specify the marks that can be controlled by this plugin.  
Only supports Alphabetical marks at the moment.  
Default: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'  

`g:MarkMyWords_WrapJumps` : Specify if jumping to marks should wrap-around.  
Default: 1

`g:MarkMyWords_leader` : Set the key used to Toggle Marks. If this key is set to `<leader>m,`  
  `<leader>ma` will toggle the mark 'a'  
  `<leader>m,` will place the next available mark  
  `<leader>m<Space>` will delete all marks  
Default: m  

## Mappings
`<Plug>MMW_NextSpotByPos`   : Jump to next mark  
`<Plug>MMW_PrevSpotByPos`   : Jump to prev mark  
`<Plug>MMW_NextSpotByAlpha` : Jump to next mark by Alphabetical Order  
`<Plug>MMW_PrevSpotByAlpha` : Jump to prev mark by Alphabetical Order  
`<Plug>MMW_NextLineByPos`   : Jump to beginning of next line containing a mark  
`<Plug>MMW_PrevLineByPos`   : Jump to beginning of prev line containing a mark  
`<Plug>MMW_NextLineByAlpha` : Jump to next line by Alphabetical Order  
`<Plug>MMW_PrevLineByAlpha` : Jump to next prev by Alphabetical Order  

## Default Mappings
```
nmap '] <Plug>MMW_NextLineByAlpha
nmap '[ <Plug>MMW_PrevLineByAlpha
nmap `] <Plug>MMW_NextSpotByAlpha
nmap `[ <Plug>MMW_PrevSpotByAlpha
nmap ]' <Plug>MMW_NextLineByPos
nmap [' <Plug>MMW_PrevLineByPos
nmap ]` <Plug>MMW_NextSpotByPos
nmap [` <Plug>MMW_PrevSpotByPos
```
This will allow the use of default behavior of m to set marks and, if the line already contains the mark, it'll be unset.  
Default behavior of ]', [', ]_`_ and [_`_ enhanced by wrapped jumps.  
To disable the default mappings and use custom mappings, set
    let g:MarkMyWords_DefaultMappings = 0

## Thanks to...
* Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
* Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)  

Here I feel obligated to mention that as some portions were coded so well by them, I could think of no way to improve them and I've just used it as is.
Well, you know what they say... _"Good coders use; great coders reuse"_ ;)

## ToDo:
* Add color support for signs
* Add custom character display support for signs
* Add support for non-Alphabetical marks

# vim-signature
vim-signature is a plugin to toggle, display and navigate marks.  
What are marks you say... Read [this](http://vim.wikia.com/wiki/Using_marks)
  
Wait a minute...isn't this done not only well but excellently so by vim-showmarks
and mark-tools; why another plugin you say?  
Well, you are right. However, I got a little impatient with the delay between
setting and display of marks in vim-showmarks and  
I liked the navigation options which mark-tools provided and I didn't want to
use two plugins where one would do and  
I was bored and felt like writing my own...  
  
Are you convinced yet or do you want me to go on? Anyway, that's how vim-signature was born.
Oh, and I also added some touches of my own such as
* Displaying multiple marks (upto 2, limited by the signs feature)  
* Placing custom signs !@#$%^&*() as visual markers  
  
### Screenshots
[Click](http://imgur.com/a/bPp3m#0)

### Vim.org mirror
If you like the plugin, spread the love and rate at http://www.vim.org/scripts/script.php?script_id=4118  


## Requirements
Requires Vim to be compiled with +signs to display marks.


## Installation
I highly recommend using Pathogen or Vundler to do the dirty work for you. If
for some reason, you do not want to use any of these excellent plugins, then
unzip it to your ~/.vim directory. You know how it goes...  

So, once that's done, out of the box, the followings mappings are defined by
default

````
  m[a-zA-Z]    : Toggle mark  
  m<Space>     : Delete all marks
  m,           : Place the next available mark
  ]`           : Jump to next mark
  [`           : Jump to prev mark
  ]'           : Jump to start of next line containing a mark  
  ['           : Jump to start of prev line containing a mark  
  `]           : Jump by alphabetical order to next mark  
  `[           : Jump by alphabetical order to prev mark  
  ']           : Jump by alphabetical order to start of next line containing a mark  
  '[           : Jump by alphabetical order to start of prev line containing a mark 

  m[0-9]       : Toggle the corresponding marker !@#$%^&*()
  m<S-[0-9]>   : Remove all markers of the same type  
  ]=           : Jump to next line having same marker  
  ]-           : Jump to prev line having same marker  
  m<BackSpace> : Remove all markers  
````

This will allow the use of default behavior of m to set marks and, if the line
already contains the mark, it'll be unset.  
The default behavior of `]'`, `['`, ``]` `` and ``[` `` is supported and enhanced by
wrapping around when beginning or end of file is reached.  
  
The command `:SignatureToggle` can be used to show/hide the signs.
Note that this does not delete any of the marks but only hides them.
This is a buffer-specific command.  
  
If for some reason, the marks and their sign displays go out of sync, 
use `:SignatureRefreshDisplay` to... well, refresh the display.  
  

## Customisation
The defaults not to your liking bub? Have no fear; use the following
variables to set things just the way you want it  

* `g:SignatureIncludeMarks` ( Default : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' )  
  Specify the marks that can be controlled by this plugin.
  Only supports Alphabetical marks at the moment.  
  `b:SignatureIncludeMarks` can be set separately to specify buffer-specific settings.  
  
* `g:SignatureWrapJumps` ( Default : 1 )  
  Specify if jumping to marks should wrap-around.
  `b:SignatureWrapJumps` can be set to specify buffer-specific settings.  
  
* `g:SignatureMarkLeader` ( Default: m )  
  Set the key used to toggle marks.  If this key is set to `<leader>m`,  
    `<leader>ma` will toggle the mark 'a'  
    `<leader>m,` will place the next available mark  
    `<leader>m<Space>` will delete all marks  

* `g:SignatureLcMarkStr` ( Default : "\p\m" )  
  Set the manner in which local (lowercase) marks are displayed.  
  `g:SignatureUcMarkStr` ( Default : "\p\m" )  
  Set the manner in which global (uppercase) marks are displayed. Similar to above.  
  `b:SignatureLcMarkStr` and `b:SignatureUcMarkStr`can be set separately to specify buffer-specific settings.  
  
`\m` represents the latest mark added and `\p`, the one previous to it.
````
  g:SignatureLcMarkStr = "\m."  : Display last mark with '.' suffixed  
  g:SignatureLcMarkStr = "_\m"  : Display last mark with '_' prefixed  
  g:SignatureLcMarkStr = ">"    : Display ">" for a line containing a mark. The mark is not displayed  
  g:SignatureLcMarkStr = "\m\p" : Display last two marks placed  
````

You can display upto 2 characters. That's a limitation imposed by the signs
feature; nothing I can do about it : / .  
Setting the MarkStr to a single character will not suffix the mark.
Don't be lazy people, if you want to see the mark, set it accordingly.  
Oh, and see in all the above strings, I've used double-quotes and not
single-quotes. That's not cause I love 'em but things go haywire if
double-quotes aren't used. Also, `\m` and `\p` cannot be set to _Space_  

* `g:SignatureMarkerLeader` ( Default: m )  
  Set the key used to toggle markers.  If this key is set to `<leader>m`  
    `<leader>m1` will toggle the marker '!'  
    `<leader>m!` will remove all the '!' markers  
  
* `g:SignatureIncludeMarkers` ( Default : '!@#$%^&*()' )
  Specify the markers that can be used by the plugin.
  `b:SignatureIncludeMarkers` can be specified separately for buffer-specific settings  

* `g:SignatureDefaultMappings` ( Default : 1 )  
  Affects all settings which have <Plug> defined. Will use the default mappings specified above.  

````
  <Plug>SIG_PlaceNextMark    : Place next available mark ( m, )
  <Plug>SIG_PurgeMarks       : Remove all marks ( m<Space> )
  <Plug>SIG_PurgeMarkers     : Remove all markers ( m<BackSpace> ) 
  <Plug>SIG_NextSpotByPos    : Jump to next mark ( ]` ) 
  <Plug>SIG_PrevSpotByPos    : Jump to prev mark ( [` ) 
  <Plug>SIG_NextLineByPos    : Jump to start of next line containing a mark ( ]' ) 
  <Plug>SIG_PrevLineByPos    : Jump to start of prev line containing a mark ( [' )  
  <Plug>SIG_NextSpotByAlpha  : Jump by alphabetical order to next mark ( `] )  
  <Plug>SIG_PrevSpotByAlpha  : Jump by alphabetical order to prev mark ( `[ )  
  <Plug>SIG_NextLineByAlpha  : Jump by alphabetical order to start of next line containing a mark ( '] )  
  <Plug>SIG_PrevLineByAlpha  : Jump by alphabetical order to start of prev line containing a mark ( '[ )  
  <Plug>SIG_NextMarkerByType : Jump to next line having same marker ( ]= ) 
  <Plug>SIG_PrevMarkerByType : Jump to prev line having same marker ( [- ) 
````

* `g:SignaturePurgeConfirmation` ( Default: 0 )
  An option for the more clumsy-fingered. Asks for confirmation before deleting all marks

* `g:SignatureDisableMenu` ( Default: 0 )  
  Hides the menu if set to 1  

* `g:SignatureMenuStruct` ( Default: "P&lugins.&Signature" )  
  Set where the menu options are to be displayed. For more details type,
````
  :h usr_42.txt
````

* `g:SignaturePeriodicRefresh` ( Default: 1 )  
  Enable the display to refresh periodically. Generally a good thing to have : /  


## Thanks to...
Restecp to (no, that's a reference and not a typo :P )  
* Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
* Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)  

I feel obligated to mention that as some portions were coded so well by
them, I could think of no way to improve them and I've just used it as is.  
Well, you know what they say... _"Good coders use; great coders reuse"_ ;)


## ToDo:
* Add custom color support for signs
* Add support for non-Alphabetical marks
* Tie the Signature functions to vim commands that affect mark placement

### NOTE  
vim-signature has undergone some changes recently, the biggest of which are  
* Maps are specified using a hash. My hope is that this will allow finer control over which maps to enable/disable and eliminate all the default mapping variables  
* Maps are now global by default. It was cumbersome to think of a good way to implement buffer-specific maps and support it. The previous method was clunky at best ( see the number of issues related to maps ) and caused more trouble than they were worth. So I decided to get rid of it.  

Q. So how does this affect me?  
A. Well, if you were using the default maps then I've tried to change things as little as possible (at least in the frontend) and I hope it shouldn't. But if you were using custom maps, then you'll have to set it up again using the new hash method.  

Q. Are there any changes not related to maps?
A. Why yes, there is now a new method to jump to marker of any type. This is mapped to `]=` and `[=` by default.  
   There is also a new setting to control if the signs should be shown by default at startup. Check out g:SignatureEnabledAtStartup  

For those who wish to continue the older version, I've created a new branch `stable_4104e0bb6c`  
  

# vim-signature
vim-signature is a plugin to place, toggle and display marks.  
  
Apart from the above, you can also  
* Navigate forward/backward by position/alphabetical order  
* Displaying multiple marks (upto 2, limited by the signs feature)  
* Placing custom signs !@#$%^&*() as visual markers  


### Screenshots  
![vim-signature_marks_markers](https://github.com/kshenoy/vim-signature/blob/images/screens/vim-signature_marks_markers.png?raw=true)  
Displays the marks as signs. Also place visual markers  
  
![Mark jumps](https://github.com/kshenoy/vim-signature/blob/images/screens/vim-signature_mark_jumps.gif?raw=true)  
Alphabetical mark traversal and more.  

More screenshots [here](http://imgur.com/a/3KQyt)  
  
### Vim.org mirror  
If you like the plugin, spread the love and rate at http://www.vim.org/scripts/script.php?script_id=4118  


## Requirements  
Requires Vim to be compiled with +signs to display marks.  


## Installation
I recommend using a plugin manager to do the grunt work for you.  
If for some reason, you do not want to use any of them, then unzip the contents of the .zip file to your ~/.vim directory.  

Once that's done, out of the box, the followings mappings are defined  

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
  ]-           : Jump to next line having same marker
  [-           : Jump to prev line having same marker
  ]=           : Jump to next line having same marker
  [=           : Jump to prev line having same marker
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
use `:SignatureRefresh` to refresh them.

For more details on customization refer the help


## Thanks to...
* Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
* Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)


## ToDo:
* Tie the Signature functions to vim commands that affect mark placement

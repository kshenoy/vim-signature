# vim-signature
vim-signature is a plugin to place, toggle and display marks.  
  
Apart from the above, you can also  
* Navigate forward/backward by position/alphabetical order  
* Displaying multiple marks (upto 2, limited by the signs feature)  
* Placing custom signs !@#$%^&*() as visual markers  


### Screenshots  
[Click](http://imgur.com/a/3KQyt)  
  
### Vim.org mirror  
If you like the plugin, spread the love and rate at http://www.vim.org/scripts/script.php?script_id=4118  


## Requirements  
Requires Vim to be compiled with +signs to display marks.  


## Installation
I highly recommend using Pathogen or Vundler to do the grunt work for you.  
If for some reason, you do not want to use any of these excellent plugins,  
then unzip it to your ~/.vim directory. You know how it goes...  

Once that's done, out of the box, the followings mappings are defined by default  

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

For more details on customization refer the help


## Thanks to...
* Sergey Khorev for [mark-tools](http://www.vim.org/scripts/script.php?script_id=2929)
* Zak Johnson for [vim-showmarks](https://github.com/zakj/vim-showmarks)


## ToDo:
* Add custom color support for signs
* Add support for non-Alphabetical marks
* Tie the Signature functions to vim commands that affect mark placement

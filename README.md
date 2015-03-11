## Acid
Acid is a Ruby gem meant to be used as a wrapper for `Open3.popen3`. It can be run as a standalone program or used as a library.

It is currently used by [Lysergide](https://github.com/trapped/lysergide), a Continuous Integration service meant to replace in-house Jenkins as a simpler but less secure alternative.
#### Standalone
`bin/acid` runs in the working directory and executes the acid.yml file, if it exists. Outputs to stdout.

#####Environmental variables
`acid` obeys the following environmental variables:

- LOG_LEVEL: this string is evaluated (only when run as standalone); should be one of the constants in `Logger` (like `Logger::ERROR`) - default `Logger::DEBUG`
- PS1: a ready-to-use prompt string (ANSI escapes are supported; bash notation is not evaluated) - default none

####Library
Acid provides a method, `Acid.start(id, dir, out = $stdout, opts = {})`, and a class, `Acid::Worker`.

- `Acid.start`
	- `id` serves just as an identifier for the worker instances when logging
	- `dir` must be set to the working directory
	- `out` is the output stream the workers will write the command output to; defaults to stdout
	- `opts` is a hash that can contain the following items:
		- `:cfg => []`, an array with filenames to check for commands to run; defaults to `['acid.yml']`
		- `:prompt => String`, a string that serves as pseudo-prompt (it is printed to the output stream before running each command together with the command itself); defaults to none
- `Acid::Worker`
	- `#new(id, env = {}, shell)`
		- items contained by `env` are set as environmental variables
		- `shell` is used as "root" process, commands are ran as arguments of this program; defaults to `bash -c` on Unix and `cmd /C` on Windows
	- `#capture(from, to, lock, &filter)`
		- `from` and `to` should be derived from `IO`
		- `lock` is released when output capture has ended (to let the runtime flush buffers)
		- `&filter` (a block), when given, is called yielding the last read data; it allows applying filters on text (e.g. colorization)
	- `#run(command, out, dir, prompt)` should need no further explanation; stderr output is colored red
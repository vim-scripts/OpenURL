"" ===========================================================================
""  Vim-plugin for opening URL's in a web-browser
""  Copyright (C) 2013  Jonas Møller <jonasmo441@gmail.com>
""
""  This program is free software: you can redistribute it and/or modify
""  it under the terms of the GNU General Public License as published by
""  the Free Software Foundation, either version 3 of the License, or
""  (at your option) any later version.
""
""  This program is distributed in the hope that it will be useful,
""  but WITHOUT ANY WARRANTY; without even the implied warranty of
""  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
""  GNU General Public License for more details.
""
""  You should have received a copy of the GNU General Public License
""  along with this program.  If not, see <http://www.gnu.org/licenses/>.
"" ===========================================================================

"" Finds urls on the current line and opens them (let's user choose, if there are several)
"" The following styles are permitted:
"" protocol://domain.extension
"" protocol://www.domain.extension
"" protocol://www.subdomain.domain.extension
"" www.domain.extension
""
"" If email adresses are found, mailtoo:// will be assumed
""
"" Permitted protocols:
"" http(s)://
"" ftp(s)://
"" mailto://

function! OpenURL()
python << EOF

import vim, re, os, webbrowser

def get(message):
	try:
		## Adapted from (as of 23-10-2013) http://vim.wikia.com/wiki/User_input_from_a_script#Python_example
		vim.command('call inputsave()')
		vim.command("let user_input = input('" + message + "')")
		vim.command('call inputrestore()')
		return vim.eval('user_input')
	except (KeyboardInterrupt, EOFError):
		return None

## Regexes
rx_http_link = re.compile(r"https?://[a-zA-Z0-9\./_%?&#=-]*")
rx_www_link = re.compile(r"www\.[a-zA-Z0-9\./_%?&#=-]*")
rx_ftp_link = re.compile(r"ftps?://[a-zA-Z0-9\./_%?&#=-]*")
rx_email_address = re.compile(r"\w*@\w*\.\w*")
rx_has_protocol = re.compile(r"^[a-zA-Z]*://")

## Make sure the URL has a valid protocol in front, assumess http
def modURL(url):
	if not rx_has_protocol.match(url):
		return "http://" + url
	return url

## Get all the matches
line = vim.current.line
urls = rx_http_link.findall(line)
urls.extend([url for url in rx_www_link.findall(line) if modURL(url) not in urls])
urls.extend(rx_ftp_link.findall(line))
urls.extend(map(lambda x: "mailto://"+x, rx_email_address.findall(line)))

if len(urls) > 1:
	choice = True; choices = [str(x+1) for x in xrange(0, len(urls))]
	while choice not in choices and choice:
		for i in xrange(0, len(urls)):
			print("{0}: {1}".format(i+1, urls[i]))
		choice = get("?> ")
	if choice:
		url = modURL(urls[int(choice)-1])
		webbrowser.open(url)
		## For some reason i have to put a CR+NL at the beginning to get a new line, don't know why but it works.
		print("\r\nOpening "+url+" ...")
elif len(urls) == 1:
	print("OpenURL: Opening "+urls[0]+" ...")
	webbrowser.open(urls[0])
else:
	print "OpenURL: No links found."

EOF
endfunction

command! -bar OpenURL call OpenURL()

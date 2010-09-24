fun! PosterousSubmit()
python << endpython
import vim
from base64 import b64encode
import urllib2, urllib

def python_input(message = 'input'):
	vim.command('call inputsave()')
	vim.command("let user_input = input('" + message + "')")
	vim.command('call inputrestore()')
	return vim.eval('user_input')

def parse_buffer():
	formdata = {}
	for line in vim.current.buffer.range(0, 9):
		field = line.split(":")[0].lower()
		data = "".join(line.split(":")[1:]).strip()
		formdata[field] = data
	formdata['body'] = "\n".join(vim.current.buffer[9:])
	return formdata

formdata = parse_buffer()

content = {
	"title": formdata['title'],
	"body": formdata['body'],
	"private": formdata['private'],
	"autopost": formdata['autopost'],
	"tags": formdata['tags'],
}

url = "http://posterous.com/api/newpost"
auth = { "Authorization": "Basic %s" % b64encode("%s:%s" % (formdata['email'], formdata['password'])) }
request = urllib2.Request(url, None, auth)

urllib2.urlopen(request, urllib.urlencode(content))
print formdata['body']
print "Done! Uploaded '%s'" % formdata['title']
endpython
endfun

" ------------------------------------------------------------------------------
fun! PosterousTemplate()
python << endpython
def insert_line(line):
	vim.command(":0put='%s'" % line)


form_lines = [
	"EMAIL: ",
	"PASSWORD: ",
	"AUTOPOST: 0",
	"PRIVATE: 0",
	"TITLE: ",
	"TAGS: ",
	"",
	"body goes under the following line and is automatically be surrounded by <markup></markup> tags.",
	"=========================",
]

if vim.current.buffer[len(form_lines)-1] != form_lines[-1]:
	for line in form_lines[::-1]:
		insert_line(line)
	
endpython
endfun

command! -nargs=* -complete=file PosterousTemplate call PosterousTemplate()
command! -nargs=* -complete=file PosterousSubmit call PosterousSubmit()

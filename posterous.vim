fun! Posterous()
python << endpython

import vim
from base64 import b64encode
from xml.dom import minidom as xml_dom
import urllib2, urllib

#----- Vim Helper Functions -----#

def python_input(message = 'input'):
	vim.command('call inputsave()')
	vim.command("let user_input = input('" + message + "')")
	vim.command('call inputrestore()')
	return vim.eval('user_input')

def insert_line(line):
	vim.command(":0put='%s'" % line)

#--------------------------------#
def Menu(header_text, options):
	""" Pass in a list of ("description", result_function) tuples """

	print header_text
	for num, option in enumerate(options):
		description, function = option
		print "%i) %s" % (num + 1, description)
	print "0) Cancel"
	
	selection = python_input("\n>>> ")
	selection = int(selection)

	if 0 < selection < len(options):
		selected_option = options[int(selection)-1]
		desc, func = selected_option
		func()

class PostForm():
	form_lines = [
		"TITLE: ",
		"TAGS: ",
		"AUTOPOST: ",
		"PRIVATE: ",
		"",
		"========== v v v POST BODY v v v ==========",
	]
	def __init__(self):
		data = {}
	
	def insert_form(self):
		if not self.is_rendered():
			for line in self.form_lines[::-1]:
				insert_line(line)

	def is_rendered(self):
		""" Check to see if the form has been rendered on the page or not. """
		buffer = vim.current.buffer
		if self.form_lines[-1] in buffer.range(0, len(self.form_lines)):
			return True
		else:
			return False
	
	def parse_fields(self):
		for line in vim.current.buffer.range(0, 9):
			# line format-- "FIELD: DATA"
			field = line.split(":")[0].lower()
			data = "".join(line.split(":")[1:]).strip()
			self.data[field] = data
		self.data['body'] = "\n".join(vim.current.buffer[9:])

	def parse_data(self):
		self.data = {
			"title": formdata['title'],
			"body": formdata['body'],
			"private": formdata['private'],
			"autopost": formdata['autopost'],
			"tags": formdata['tags'],
		}

class Posterous:
	newpost_url = "http://posterous.com/api/newpost"
	getsites_url = "http://posterous.com/api/getsites"

	def __init__(self):
		self.email = ""
		self.password = ""
		self.authentication = {}
		self._auth_is_valid = False
		self.sites = []
	
	def generate_authentication(self):
		self.authentication = { "Authorization": "Basic %s" % b64encode("%s:%s" % (self.email, self.password)) }

	def get_login(self):
		self.email = python_input("Email Address: ")
		self.password = python_input("Password: ")

	def get_sites(self):
		self.get_login()
		self.generate_authentication()

		try:
			request = urllib2.Request(self.getsites_url, None, self.authentication)
			payload = urllib2.urlopen(request)
			self._auth_is_valid = True
		except urllib2.HTTPError:
			print "There was an error logging in."
			self._auth_is_valid = False
			return []

		self.sites = [] # Empty existing sites.

		xml_payload = xml_dom.parse(payload)
		response = xml_payload.firstChild
		status = response.attributes["stat"].value
		index = 1
		while index < len(response.childNodes):
			site = response.childNodes[index]
			site_id = site.childNodes[1].firstChild.data
			site_name = site.childNodes[3].firstChild.data
			self.sites.append((site_id, site_name))
			index += 2
	
	def select_site(self):
		self.fetch_sites()
		
		for site_id, site_name in self.sites:
			print site_id, site_name
	
	def submit_post(self, data):
		pass

Menu("Pick something damnit", [
	("Option 1", lambda: "one"),
	("Option 2", lambda: "two"),
	])
posterous = Posterous()
# posterous.select_site()
post_form = PostForm()
# post_form.insert_form()

endpython
endfun

" ------------------------------------------------------------------------------

command! -nargs=* -complete=file Posterous call Posterous()

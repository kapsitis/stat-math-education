import webapp2
import os
import jinja2

jinja_env = jinja2.Environment(
    loader = jinja2.FileSystemLoader(os.path.dirname(__file__)))

class HomeHandler(webapp2.RequestHandler): 
    def get(self, my_id):
        template_context = {
            'key': 'Labdien!'
        }
        template = jinja_env.get_template('index.html')
        output = template.render(template_context)
        self.response.out.write(output.encode('utf-8'))

app = webapp2.WSGIApplication([
    ('/(.*)', HomeHandler)
], debug=True)
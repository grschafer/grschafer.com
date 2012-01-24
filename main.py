#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import os
from google.appengine.ext.webapp import template
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util


class IndexPage(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'index.html')
        self.response.out.write(template.render(path, {}))
class Omgpop(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'omgpop.html')
        self.response.out.write(template.render(path, {}))
class LaundryMon(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'laundrymon.html')
        self.response.out.write(template.render(path, {}))
class Memory(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'memory.html')
        self.response.out.write(template.render(path, {}))
class Particles(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'particles.html')
        self.response.out.write(template.render(path, {}))
class Perlin(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'perlin.html')
        self.response.out.write(template.render(path, {}))
class Spanish(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'spanish.html')
        self.response.out.write(template.render(path, {}))
class Spinmaze(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'spinmaze.html')
        self.response.out.write(template.render(path, {}))
class Tetradrop(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'tetradrop.html')
        self.response.out.write(template.render(path, {}))


def main():
    application = webapp.WSGIApplication([('/', IndexPage),
                                          ('/omgpop', Omgpop),
                                          ('/laundrymon', LaundryMon),
                                          ('/memory', Memory),
                                          ('/particles', Particles),
                                          ('/perlin', Perlin),
                                          ('/spanish', Spanish),
                                          ('/spinmaze', Spinmaze),
                                          ('/tetradrop', Tetradrop),
                                          ],
                                         debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()

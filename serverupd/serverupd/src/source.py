import logging
import json
from socket import * 
from urllib.request import Request, urlopen
from urllib.parse import urlparse
from urllib.error import URLError
from certifi import where
from ssl import create_default_context, Purpose

class Source:
    def __init__(self, path) -> None:
            self.path = path
            self.scheme = urlparse(path).scheme
            self.name = urlparse(path).path.split("/")[-1]
        
    def jsonObj(self):
        if self.scheme =="":
            return self._jsonFromFile()
        else:
            return self._jsonFromUrl()

    def _jsonFromUrl(self):
        context = create_default_context(purpose=Purpose.SERVER_AUTH, cafile=where())
        req = Request(self.path)
        try:
            return json.loads(urlopen(req, context=context).read().decode("utf-8"))
        except URLError:
            logging.error(f"{__name__}:failed to connect to the given url")
        except json.JSONDecodeError:
            print(urlopen(req, context=context).read().decode("utf-8"))
            logging.error(f"{__name__}:failed to parse{self.path}")
        except socket.TimeoutError:
            logging.error(f"{__name__}:socket timeout error")

    def _jsonFromFile(self):
        try:
            with open(self.path,"r") as f:
                return json.load(f)
        except FileNotFoundError as e:
            logging.error(f"{__name__}:file not found. check the path to your file")
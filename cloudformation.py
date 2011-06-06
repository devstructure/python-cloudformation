"""
Tools for creating CloudFormation templates.
"""

from collections import defaultdict
import json

def _dict_property(name):
    """
    Return a property that gets and sets the given dictionary item.
    """
    def get(self):
        return self[name]
    def set(self, value):
        self[name] = value
    return property(get, set)

class Template(defaultdict):
    """
    A CloudFormation template.
    """

    def __init__(self, *args, **kwargs):
        """
        Initialize a neverending tree of Template objects.
        """
        super(self.__class__, self).__init__(*args, **kwargs)
        self.default_factory = lambda: self.__class__(self.__class__)
        self.user_data = []

    # Shortcuts to the typical keys in a Template template.
    Description = _dict_property('Description')
    Mappings = _dict_property('Mappings')
    Outputs = _dict_property('Outputs')
    Parameters = _dict_property('Parameters')
    Resources = _dict_property('Resources')

    def add(self, key, *args, **kwargs):
        """
        Add an item to this CloudFormation template.  This is typically
        called on non-root Template objects, for example

            t.Parameters.add(...)

        to add an item to the Parameters object.
        """
        self[key] = self.__class__(*args, **kwargs)

    def add_user_data(self, f):
        """
        Read user data from the given file-like object, parse it, and store
        it.  Lines containing the "____" interpolation marker will be
        reconstituted later.
        """
        for line in f:
            self.user_data.append(line.rstrip().split('____'))

    def dumps(self, pretty=True):
        """
        Return a string representation of this CloudFormation template.
        """
        self['AWSTemplateFormatVersion'] = '2010-09-09'
        return json.JSONEncoder(indent=2 if pretty else None,
                                sort_keys=True).encode(self)

    def ref_user_data(self, *args):
        """
        Write out the appropriate function calls and references to pass user
        data to an instance.  Do not call this before calling add_user_data.

        This method skimps on error checking so make sure you pass the same
        number of arguments as there are interpolation markers in the user
        data, otherwise the result will be wrong or raise StopIteration.
        """
        iterargs = iter(args)
        lines = []
        for parts in self.user_data:
            if 1 == len(parts):
                lines.append(parts[0])
            else:
                line = []
                for part in parts:
                    line.extend([part, None])
                line.pop()
                for i in range(len(line)):
                    if line[i] is None:
                        line[i] = iterargs.next()
                lines.append({'Fn::Join': ['', line]})
        return {'Fn::Base64': {'Fn::Join': ['\n', lines]}}

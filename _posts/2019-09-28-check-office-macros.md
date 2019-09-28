---
layout: post
title: Analyzing Office macros
subtitle: Preventing Emotet to infect everyone
tags: [emotet, malware, oletools, python]
image: '/img/microsoft-office.png'
bigimg: '/img/emotet.jpg'
---

With [Emotet](https://www.malwarebytes.com/emotet/) hitting in the wild, analyzing Office files for potentially malicious macros is crucial.

There is a well-known set of utilities by [Philippe Lagadec](https://github.com/decalage2) called (python-oletools)[http://www.decalage.info/python/oletools]. Lots of services like [Cuckoo Sandbox](https://github.com/cuckoosandbox/cuckoo), [Hybrid-analysis.com](https://www.hybrid-analysis.com/) and maybe even [VirusTotal](https://www.virustotal.com/) are using it.

According to the author:

> python-oletools is a package of python tools to analyze Microsoft OLE2 files (also called Structured Storage, Compound File Binary Format or Compound Document File Format), such as Microsoft Office documents or Outlook messages, mainly for malware analysis, forensics and debugging. It is based on my olefile parser.

## Example code

`oletools` can be used as a CLI tool:

```bash
$ olevba ../in/*
olevba 0.54.2 on Python 3.5.3 - http://decalage.info/python/oletools
Flags        Filename                                                         
-----------  -----------------------------------------------------------------
OLE:MASI---- ../in/doc (1).doc
OpX:-------- ../in/foo.xlsx
OpX:-------- ../in/2018.xlsx
OLE:MASI---- ../in/invoice.doc
OpX:-------- ../in/invoice (2).docx
TXT:M------- ../in/test.txt
WARNING  msoffcrypto failed to interpret file ../in/test.txt or determine whether it is encrypted: Unsupported file format
WARNING  Failed to check ../in/test.txt for encryption (not an OLE2 structured storage file); assume it is not encrypted.

(Flags: OpX=OpenXML, XML=Word2003XML, FlX=FlatOPC XML, MHT=MHTML, TXT=Text, M=Macros, A=Auto-executable, S=Suspicious keywords, I=IOCs, H=Hex strings, B=Base64 strings, D=Dridex strings, V=VBA strings, ?=Unknown)
```

Take a look at the flags: aside from the type of document (OpenXML, Text, etc.) you can see the different patterns found like

> auto-executable macros, suspicious VBA keywords used by malware, anti-sandboxing and anti-virtualization techniques, and potential IOCs (IP addresses, URLs, executable filenames, etc) ([see olevba documentation](https://github.com/decalage2/oletools/wiki/olevba))

You can run triage for a single document:

```bash
$ olevba -t  ../queue/2019N00002453\ \(1\).doc |more
olevba 0.54.2 on Python 3.5.3 - http://decalage.info/python/oletools
Flags        Filename                                                         
-----------  -----------------------------------------------------------------
OLE:MASI---- ../queue/2019N00002453 (1).doc
```

...or see the full details (default behaviour):

```bash
$ olevba -a in/invoice (1).doc
olevba 0.54.2 on Python 3.5.3 - http://decalage.info/python/oletools
===============================================================================
FILE: in/2019N00002453 (1).doc
Type: OLE
-------------------------------------------------------------------------------
VBA MACRO Paradigmfim.cls
in file: in/2019N00002453 (1).doc - OLE stream: 'Macros/VBA/Paradigmfim'
-------------------------------------------------------------------------------
VBA MACRO Sleek_Soft_Pizzafwu.bas
in file: in/2019N00002453 (1).doc - OLE stream: 'Macros/VBA/Sleek_Soft_Pizzafwu'
-------------------------------------------------------------------------------
VBA MACRO Frozenapw.bas
in file: in/2019N00002453 (1).doc - OLE stream: 'Macros/VBA/Frozenapw'
+----------+--------------------+---------------------------------------------+
|Type      |Keyword             |Description                                  |
+----------+--------------------+---------------------------------------------+
|AutoExec  |autoopen            |Runs when the Word document is opened        |
|Suspicious|virtual             |May detect virtualization                    |
|Suspicious|ShowWindow          |May hide the application                     |
|Suspicious|CreateObject        |May create an OLE object                     |
|Suspicious|open                |May open a file                              |
|Suspicious|system              |May run an executable file or a system       |
|          |                    |command on a Mac (if combined with           |
|          |                    |libc.dylib)                                  |
|IOC       |https://www.microsof|URL                                          |
|          |t.com/library/errorp|                                             |
|          |ages/smarterror.aspx|                                             |
|          |?correlationId=gener|                                             |
|          |atejjt              |                                             |
```

You can also extract macros, unzip zipped documents (even with password), etc. Complete documentation is available.

## Use as a Python module

`oletools` can be used as a Python module as well. For example, this piece of code:

```Python
#!/usr/bin/env python3

import sys
import os
import json
from oletools.olevba import VBA_Parser

def scan(filename):
    score = {}
    try:
        vbaparser = VBA_Parser(filename)
    except:
        print("File type not supported")
        sys.exit(1)

    if vbaparser.detect_vba_macros():
        print("Parsing {}".format(filename))
        results = vbaparser.analyze_macros()
        vbaparser.close()

        # for kw_type, keyword, description in results:
        #     print('type={} - keyword={} - description={}'.format(kw_type, keyword, description))
        # print(results)

        for kw_type, keyword, description in results:
            if not kw_type in score:
                score[kw_type] = 1
            else:
                score[kw_type] += 1
            # print('type={} - keyword={}'.format(kw_type, description))
        for k in score:
            print(k, score[k])
    else:
        print('No VBA Macros found')


def main(filename):
    if os.path.isfile(filename):
        scan(filename)
    else:
        print("{} does not exist".format(filename))
        sys.exit(1)

if __name__ == '__main__':
    main(sys.argv[1])
```

will output:

```bash
$ ./analysis.py ../queue/invoice.doc
IOC 94
AutoExec 1
Suspicious 5
```

You can [get the code at gist](https://gist.github.com/lmarqueta/0d034bc920fc9d7a363843441f34118d)

## References

* [US-CERT Alert (TA18-201A) Emotet Malware](https://www.us-cert.gov/ncas/alerts/TA18-201A)

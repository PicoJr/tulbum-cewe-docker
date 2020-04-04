#!/bin/bash
sed -i '/system("less $FILE_EULA");/d' install.pl
sed -i '/showEula();/d' install.pl

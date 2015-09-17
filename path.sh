#!/bin/sh

echo $PWD | sed -e "s,$HOME,\~,g" -e 's,^.*/\([^/]\+\/[^/]\+$\),\1,g'

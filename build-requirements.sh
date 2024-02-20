#!/bin/bash

echo "" > spacy-requirements.txt

while read m; do
    echo "looking up $m ..."
    echo "`spacy info $m --url`" >> spacy-requirements.txt
done < "./spacy-models.txt"

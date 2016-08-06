#!/usr/bin/env bash
java -jar $HOME/.vim/plantuml/plantuml.jar -tutxt $@

fname=$(sed -e 's/\.uml$/\.utxt/' <<< $@)
newFname=$(sed -e 's/\.uml$/\.txt/' <<< $@)

mv $fname $newFname

echo >> $newFname
echo >> $newFname
echo >> $newFname
echo "_________________________________________________________" >> $newFname
echo >> $newFname
echo "Produced with Plantuml : http://plantuml.com/plantuml/uml" >> $newFname
echo >> $newFname
echo "Code:" >> $newFname
cat $@ >> $newFname

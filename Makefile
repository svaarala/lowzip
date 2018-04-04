.PHONY: default
default: test_lowzip

.PHONY: clean
clean:
	-@rm -f *.pyc
	-@rm -f *.o
	-@rm -f test_lowzip
	-@rm -rf cantrbry
	-@rm -rf artificl
	-@rm -rf large
	-@rm -rf misc
	-@rm -rf calgary
	-@rm -f sf-city-lots-json/citylots.json.deflate

.PHONY: cleanall
cleanall: clean
	-@rm -f cantrbry.zip
	-@rm -f artificl.zip
	-@rm -f large.zip
	-@rm -f misc.zip
	-@rm -f calgary.zip
	-@rm -rf sf-city-lots-json
	-@rm -rf scriptorium

lowzip.o: lowzip.c lowzip.h
	gcc -c -o lowzip.o -Os -g -ggdb -Wall -Wextra -std=c99 -fomit-frame-pointer lowzip.c
	size $@
test_lowzip: test_lowzip.c lowzip.o
	gcc -o $@ -Os -g -ggdb -Wall -Wextra -std=c99 -fomit-frame-pointer test_lowzip.c lowzip.o
	size $@

.PHONY: test
test: test-inf test-zip

.PHONY: test-zip
test-zip: test_lowzip calgary.zip scriptorium
	valgrind -q ./test_lowzip cantrbry.zip
	test "`valgrind -q ./test_lowzip cantrbry.zip alice29.txt | md5sum | cut -d ' ' -f 1`" = "74c3b556c76ea0cfae111cdb64d08255"
	test "`valgrind -q ./test_lowzip --test-repeat cantrbry.zip alice29.txt | md5sum | cut -d ' ' -f 1`" = "397e1b669cd13f15824b1f44012a70e8"  # repeat 3 times
	test "`valgrind -q ./test_lowzip cantrbry.zip asyoulik.txt | md5sum | cut -d ' ' -f 1`" = "2183e4e23c67c1dcc6cb84e13d8863bf"
	test "`valgrind -q ./test_lowzip cantrbry.zip cp.html | md5sum | cut -d ' ' -f 1`" = "d4b4e81b46ae7a3cbc2b733bbd6d8cc8"
	test "`valgrind -q ./test_lowzip cantrbry.zip fields.c | md5sum | cut -d ' ' -f 1`" = "82640457a3569c49615974b5053a73df"
	test "`valgrind -q ./test_lowzip cantrbry.zip grammar.lsp | md5sum | cut -d ' ' -f 1`" = "ad6ff075a8058262564493050f67f702"
	test "`valgrind -q ./test_lowzip cantrbry.zip kennedy.xls | md5sum | cut -d ' ' -f 1`" = "b408d2207b18aba5a378548698735d64"
	test "`valgrind -q ./test_lowzip cantrbry.zip lcet10.txt | md5sum | cut -d ' ' -f 1`" = "5d69b132c7929dec190daa69f081d472"
	test "`valgrind -q ./test_lowzip cantrbry.zip plrabn12.txt | md5sum | cut -d ' ' -f 1`" = "4655507b26054b80b98bac2b44d8200f"
	test "`valgrind -q ./test_lowzip cantrbry.zip ptt5 | md5sum | cut -d ' ' -f 1`" = "29eca86237730fce52232612036284b9"
	test "`valgrind -q ./test_lowzip cantrbry.zip sum | md5sum | cut -d ' ' -f 1`" = "0d347e6c137c15616ee2becc0123e0a3"
	test "`valgrind -q ./test_lowzip cantrbry.zip xargs.1 | md5sum | cut -d ' ' -f 1`" = "7bcc27abddbcc8dc56d9b1950ce93a69"
	valgrind -q ./test_lowzip artificl.zip
	test "`valgrind -q ./test_lowzip artificl.zip a.txt | md5sum | cut -d ' ' -f 1`" = "0cc175b9c0f1b6a831c399e269772661"
	test "`valgrind -q ./test_lowzip artificl.zip aaa.txt | md5sum | cut -d ' ' -f 1`" = "1af6d6f2f682f76f80e606aeaaee1680"
	test "`valgrind -q ./test_lowzip artificl.zip alphabet.txt | md5sum | cut -d ' ' -f 1`" = "eeb430124056cecabbfbc7e88a1a8b46"
	test "`valgrind -q ./test_lowzip artificl.zip random.txt | md5sum | cut -d ' ' -f 1`" = "0e9cb1628d455e9d7723bcb3a6c5da18"
	valgrind -q ./test_lowzip large.zip
	test "`valgrind -q ./test_lowzip large.zip bible.txt | md5sum | cut -d ' ' -f 1`" = "93fb92788b569c0387a50f4c99720ee7"
	test "`valgrind -q ./test_lowzip large.zip E.coli | md5sum | cut -d ' ' -f 1`" = "e847a1b370f150bb96904a463cef9c8b"
	test "`valgrind -q ./test_lowzip large.zip world192.txt | md5sum | cut -d ' ' -f 1`" = "30500a27cb7a15e6f2fa0032b06e06c3"
	valgrind -q ./test_lowzip misc.zip
	test "`valgrind -q ./test_lowzip misc.zip pi.txt | md5sum | cut -d ' ' -f 1`" = "99e38ddabac48d5b156ae7c154055367"
	valgrind -q ./test_lowzip calgary.zip
	test "`valgrind -q ./test_lowzip calgary.zip bib | md5sum | cut -d ' ' -f 1`" = "d45d5d7b6f908c18a8a76cca9744a970"
	test "`valgrind -q ./test_lowzip calgary.zip book1 | md5sum | cut -d ' ' -f 1`" = "0a0fdbaf0589c9713bde9120cbb20199"
	test "`valgrind -q ./test_lowzip calgary.zip book2 | md5sum | cut -d ' ' -f 1`" = "c529dcfed445b656db844b3b8133d0dd"
	test "`valgrind -q ./test_lowzip calgary.zip geo | md5sum | cut -d ' ' -f 1`" = "23642c127bdf1c964fbfd5330fad35c0"
	test "`valgrind -q ./test_lowzip calgary.zip news | md5sum | cut -d ' ' -f 1`" = "43a8e87a4af8e29a07dd67f21bc0598c"
	test "`valgrind -q ./test_lowzip calgary.zip obj1 | md5sum | cut -d ' ' -f 1`" = "54772267d11d18d972f4b85386e7414c"
	test "`valgrind -q ./test_lowzip calgary.zip obj2 | md5sum | cut -d ' ' -f 1`" = "58a94ec5245a7039ad9c1dafce6d4e12"
	test "`valgrind -q ./test_lowzip calgary.zip paper1 | md5sum | cut -d ' ' -f 1`" = "2687bd7a2b6da940452d07a57778430c"
	test "`valgrind -q ./test_lowzip calgary.zip paper2 | md5sum | cut -d ' ' -f 1`" = "1d46f1ed5c91c7aff89aacb27a9d4c45"
	test "`valgrind -q ./test_lowzip calgary.zip paper3 | md5sum | cut -d ' ' -f 1`" = "6da289bac0a9b89b1f9c6ce7ff092049"
	test "`valgrind -q ./test_lowzip calgary.zip paper4 | md5sum | cut -d ' ' -f 1`" = "daed0ca8a863978f5f3321eccb58676c"
	test "`valgrind -q ./test_lowzip calgary.zip paper5 | md5sum | cut -d ' ' -f 1`" = "fc6dc510d8efb378f33426927c3bb79e"
	test "`valgrind -q ./test_lowzip calgary.zip paper6 | md5sum | cut -d ' ' -f 1`" = "6496a0bafa5f9a7f305b09732fd478ce"
	test "`valgrind -q ./test_lowzip calgary.zip pic | md5sum | cut -d ' ' -f 1`" = "29eca86237730fce52232612036284b9"
	test "`valgrind -q ./test_lowzip calgary.zip progc | md5sum | cut -d ' ' -f 1`" = "237810d59b006d7dc03ba4afa47342d9"
	test "`valgrind -q ./test_lowzip calgary.zip progl | md5sum | cut -d ' ' -f 1`" = "b9dc47bbc625276dd1c403fbc8efa171"
	test "`valgrind -q ./test_lowzip calgary.zip progp | md5sum | cut -d ' ' -f 1`" = "3aa2be79cd1a96e68476829e0f6f6813"
	test "`valgrind -q ./test_lowzip calgary.zip trans | md5sum | cut -d ' ' -f 1`" = "a95453458cb440a7320ebc6215af0fd0"
	test "`valgrind -q ./test_lowzip scriptorium/terra/terra/bin/bin.zip terra.dll | md5sum | cut -d ' ' -f 1`" = "7a76618bafbfb99e4b7854a0b5206131"
	@echo "Unzip success for well-formed inputs!"

.PHONY: test-inf
test-inf: test-inf-well-formed test-inf-malformed

.PHONY: test-inf-malformed
test-inf-malformed: test_lowzip
	valgrind -q ./test_lowzip --raw-inflate --ignore-errors tests/malformed/random_1k.deflate
	@echo "Raw inflate success for malformed inputs!"

.PHONY: test-inf-well-formed
test-inf-well-formed: test_lowzip sf-city-lots-json/citylots.json.deflate cantrbry artificl large misc calgary
	test "`valgrind -q ./test_lowzip --raw-inflate tests/sizes/size_0b.deflate | md5sum | cut -d ' ' -f 1`" = "d41d8cd98f00b204e9800998ecf8427e"
	test "`valgrind -q ./test_lowzip --raw-inflate sf-city-lots-json/citylots.json.deflate | md5sum | cut -d ' ' -f 1`" = "158346af5a90253d8b4390bd671eb5c5"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/alice29.txt.deflate | md5sum | cut -d ' ' -f 1`" = "74c3b556c76ea0cfae111cdb64d08255"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/asyoulik.txt.deflate | md5sum | cut -d ' ' -f 1`" = "2183e4e23c67c1dcc6cb84e13d8863bf"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/cp.html.deflate | md5sum | cut -d ' ' -f 1`" = "d4b4e81b46ae7a3cbc2b733bbd6d8cc8"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/fields.c.deflate | md5sum | cut -d ' ' -f 1`" = "82640457a3569c49615974b5053a73df"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/grammar.lsp.deflate | md5sum | cut -d ' ' -f 1`" = "ad6ff075a8058262564493050f67f702"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/kennedy.xls.deflate | md5sum | cut -d ' ' -f 1`" = "b408d2207b18aba5a378548698735d64"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/lcet10.txt.deflate | md5sum | cut -d ' ' -f 1`" = "5d69b132c7929dec190daa69f081d472"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/plrabn12.txt.deflate | md5sum | cut -d ' ' -f 1`" = "4655507b26054b80b98bac2b44d8200f"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/ptt5.deflate | md5sum | cut -d ' ' -f 1`" = "29eca86237730fce52232612036284b9"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/sum.deflate | md5sum | cut -d ' ' -f 1`" = "0d347e6c137c15616ee2becc0123e0a3"
	test "`valgrind -q ./test_lowzip --raw-inflate cantrbry/xargs.1.deflate | md5sum | cut -d ' ' -f 1`" = "7bcc27abddbcc8dc56d9b1950ce93a69"
	test "`valgrind -q ./test_lowzip --raw-inflate artificl/aaa.txt.deflate | md5sum | cut -d ' ' -f 1`" = "1af6d6f2f682f76f80e606aeaaee1680"
	test "`valgrind -q ./test_lowzip --raw-inflate artificl/alphabet.txt.deflate | md5sum | cut -d ' ' -f 1`" = "eeb430124056cecabbfbc7e88a1a8b46"
	test "`valgrind -q ./test_lowzip --raw-inflate artificl/a.txt.deflate | md5sum | cut -d ' ' -f 1`" = "0cc175b9c0f1b6a831c399e269772661"
	test "`valgrind -q ./test_lowzip --raw-inflate artificl/random.txt.deflate | md5sum | cut -d ' ' -f 1`" = "0e9cb1628d455e9d7723bcb3a6c5da18"
	test "`valgrind -q ./test_lowzip --raw-inflate large/bible.txt.deflate | md5sum | cut -d ' ' -f 1`" = "93fb92788b569c0387a50f4c99720ee7"
	test "`valgrind -q ./test_lowzip --raw-inflate large/E.coli.deflate | md5sum | cut -d ' ' -f 1`" = "e847a1b370f150bb96904a463cef9c8b"
	test "`valgrind -q ./test_lowzip --raw-inflate large/world192.txt.deflate | md5sum | cut -d ' ' -f 1`" = "30500a27cb7a15e6f2fa0032b06e06c3"
	test "`valgrind -q ./test_lowzip --raw-inflate misc/pi.txt.deflate | md5sum | cut -d ' ' -f 1`" = "99e38ddabac48d5b156ae7c154055367"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/bib.deflate | md5sum | cut -d ' ' -f 1`" = "d45d5d7b6f908c18a8a76cca9744a970"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/book1.deflate | md5sum | cut -d ' ' -f 1`" = "0a0fdbaf0589c9713bde9120cbb20199"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/book2.deflate | md5sum | cut -d ' ' -f 1`" = "c529dcfed445b656db844b3b8133d0dd"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/geo.deflate | md5sum | cut -d ' ' -f 1`" = "23642c127bdf1c964fbfd5330fad35c0"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/news.deflate | md5sum | cut -d ' ' -f 1`" = "43a8e87a4af8e29a07dd67f21bc0598c"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/obj1.deflate | md5sum | cut -d ' ' -f 1`" = "54772267d11d18d972f4b85386e7414c"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/obj2.deflate | md5sum | cut -d ' ' -f 1`" = "58a94ec5245a7039ad9c1dafce6d4e12"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/paper1.deflate | md5sum | cut -d ' ' -f 1`" = "2687bd7a2b6da940452d07a57778430c"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/paper2.deflate | md5sum | cut -d ' ' -f 1`" = "1d46f1ed5c91c7aff89aacb27a9d4c45"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/paper3.deflate | md5sum | cut -d ' ' -f 1`" = "6da289bac0a9b89b1f9c6ce7ff092049"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/paper4.deflate | md5sum | cut -d ' ' -f 1`" = "daed0ca8a863978f5f3321eccb58676c"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/paper5.deflate | md5sum | cut -d ' ' -f 1`" = "fc6dc510d8efb378f33426927c3bb79e"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/paper6.deflate | md5sum | cut -d ' ' -f 1`" = "6496a0bafa5f9a7f305b09732fd478ce"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/pic.deflate | md5sum | cut -d ' ' -f 1`" = "29eca86237730fce52232612036284b9"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/progc.deflate | md5sum | cut -d ' ' -f 1`" = "237810d59b006d7dc03ba4afa47342d9"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/progl.deflate | md5sum | cut -d ' ' -f 1`" = "b9dc47bbc625276dd1c403fbc8efa171"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/progp.deflate | md5sum | cut -d ' ' -f 1`" = "3aa2be79cd1a96e68476829e0f6f6813"
	test "`valgrind -q ./test_lowzip --raw-inflate calgary/trans.deflate | md5sum | cut -d ' ' -f 1`" = "a95453458cb440a7320ebc6215af0fd0"
	@echo "Raw inflate success for well-formed inputs!"

# SF city lots, large JSON file
sf-city-lots-json/citylots.json.deflate: sf-city-lots-json
	nodejs nodejs_deflate.js sf-city-lots-json/citylots.json $@
sf-city-lots-json:
	git clone --depth 1 https://github.com/zemirco/sf-city-lots-json.git

# Scriptorium, terra.dll triggered a certain bug so test against it
scriptorium:
	git clone --depth 1 https://github.com/r-lyeh/scriptorium.git

# http://corpus.canterbury.ac.nz/descriptions/
cantrbry.zip:
	wget -O $@ http://corpus.canterbury.ac.nz/resources/cantrbry.zip
cantrbry: cantrbry.zip
	mkdir cantrbry
	cd cantrbry; unzip ../cantrbry.zip
	for fn in cantrbry/*; do nodejs nodejs_deflate.js $$fn $$fn.deflate; done
artificl.zip:
	wget -O $@ http://corpus.canterbury.ac.nz/resources/artificl.zip
artificl: artificl.zip
	mkdir artificl
	cd artificl; unzip ../artificl.zip
	for fn in artificl/*; do nodejs nodejs_deflate.js $$fn $$fn.deflate; done
large.zip:
	wget -O $@ http://corpus.canterbury.ac.nz/resources/large.zip
large: large.zip
	mkdir large
	cd large; unzip ../large.zip
	for fn in large/*; do nodejs nodejs_deflate.js $$fn $$fn.deflate; done
misc.zip:
	wget -O $@ http://corpus.canterbury.ac.nz/resources/misc.zip
misc: misc.zip
	mkdir misc
	cd misc; unzip ../misc.zip
	for fn in misc/*; do nodejs nodejs_deflate.js $$fn $$fn.deflate; done
calgary.zip:
	wget -O $@ http://corpus.canterbury.ac.nz/resources/calgary.zip
calgary: calgary.zip
	mkdir calgary
	cd calgary; unzip ../calgary.zip
	for fn in calgary/*; do nodejs nodejs_deflate.js $$fn $$fn.deflate; done

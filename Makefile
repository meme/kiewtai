CC=gcc
CFLAGS=-O2 -g

KSC=kaitai-struct-compiler
KFLAGS=--debug --target javascript

ksydefs=$(wildcard formats/*/*.ksy)
formats=$(wildcard parsers/*.js)

gendeps: gendeps.o duktape.o
	$(CC) $^ -o $@

jsmin: jsmin.o
	$(CC) $^ -o $@

parsers: $(ksydefs) | gendeps jsmin
	-$(KSC) $(KFLAGS) -I formats --outdir parsers $^
	cd parsers && for i in *.js; do                                            \
	    ../gendeps $${i} > $${i}.d && ../jsmin < $${i}.d > $${i};              \
	done

parsers.h: parsers
	echo // THIS IS A GENERATED FILE > $@
	for f in $(basename $(notdir $(wildcard parsers/*.js))); do                \
	    printf "extern unsigned char parsers_%s_js[];\n" $${f};            \
	    printf "extern unsigned int parsers_%s_js_len;\n" $${f};             \
	done >> $@
	
	printf "static KAITAI_PARSER KaitaiParsers[] = {\n" >> $@
	for f in $(sort $(basename $(notdir $(wildcard parsers/*.js)))); do        \
	    printf "{ \"%s\"," $${f};                                              \
	    printf "parsers_%s_js," $${f};                            \
	    printf "&parsers_%s_js_len },\n" $${f};                \
	done >> $@
	
	printf "};\n" >> $@

command: command.o kaitai.o duktape.o PolyFill.js.c KaitaiStream.js.c pako_inflate.js.c $(formats:.js=.js.c) | parsers.h
	$(CC) $^ -o $@

%.js.c: %.js
	xxd -i $^ > $@

%.o: %.c
	$(CC) $(CFLAGS) $^ -c -o $@

clean:
	rm -f *.o gendeps jsmin parsers.h
	rm -rf parsers

# 	_|
# 000063b0  62 69 6e 61 72 79 5f 4b  61 69 74 61 69 53 74 72  |binary_KaitaiStr|
# 000063c0  65 61 6d 5f 6a 73 5f 73  69 7a 65 00              |eam_js_size.|

# _binary_KaitaiStream_js_size
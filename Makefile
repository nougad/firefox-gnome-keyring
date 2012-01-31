PACKAGE          ?= firefox-gnome-keyring
VERSION          ?= $(shell git describe --tags 2>/dev/null || date +dev-%s)
# max/min compatibility versions to set, only if version detection fails
FIREFOX_VER_MIN      ?= 6.0.1
FIREFOX_VER_MAX      ?= 6.*
THUNDERBIRD_VER_MIN      ?= 6.0.1
THUNDERBIRD_VER_MAX      ?= 6.*
# package distribution variables
FULLNAME         ?= $(PACKAGE)-$(VERSION)
ARCHIVENAME      ?= $(FULLNAME)


# xulrunner tools. use = not ?= so we don't execute on every invocation
XUL_PKG_NAME     = $(shell (pkg-config --atleast-version=2 libxul && echo libxul) || (pkg-config libxul2 && echo libxul2))

# compilation flags
# TODO include path for thunderbird too
# TODO copied from ubuntus pkgconfig - evaluate
XUL_CFLAGS       := -I/usr/include/firefox/ -I/usr/include/nspr/ -I/usr/include/
XUL_LDFLAGS      := -L/usr/lib/firefox/lib/ -lplds4 -lplc4 -lnspr4 -lpthread -ldl -lxpcomglue_s -lxul -lxpcom -lmozalloc
GNOME_CFLAGS     := `pkg-config --cflags gnome-keyring-1` -DMOZ_NO_MOZALLOC
GNOME_LDFLAGS    := `pkg-config --libs gnome-keyring-1`
CPPFLAGS         += -fno-rtti -fno-exceptions -shared -fPIC -g -std=gnu++0x

# construct Mozilla architectures string
ARCH             := $(shell uname -m)
ARCH             := $(shell echo ${ARCH} | sed 's/i686/x86/')
PLATFORM         := $(shell uname)_$(ARCH)-gcc3

TARGET           := libgnomekeyring.so
XPI_TARGET       := gnome-keyring_password_integration-$(VERSION).xpi

BUILD_FILES      := \
xpi/platform/$(PLATFORM)/components/$(TARGET) \
xpi/install.rdf \
xpi/chrome.manifest


.PHONY: all build build-xpi tarball
all: build

build: build-xpi

build-xpi: $(XPI_TARGET)

$(XPI_TARGET): $(BUILD_FILES)
	cd xpi && zip -rq ../$@ *

xpi/platform/$(PLATFORM)/components/$(TARGET): $(TARGET)
	mkdir -p xpi/platform/$(PLATFORM)/components
	cp -a $< $@

xpi/install.rdf: install.rdf Makefile
	mkdir -p xpi
	FIREFOX_VER_MIN=`firefox -v | sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p'`; \
	FIREFOX_VER_MAX=`firefox -v | sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p' | sed -rn -e 's/([^.]+).*/\1.*/gp'`; \
	THUNDERBIRD_VER_MIN=`thunderbird -v | sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p'`; \
	THUNDERBIRD_VER_MAX=`thunderbird -v | sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p' | sed -rn -e 's/([^.]+).*/\1.*/gp'`; \
	sed -e 's/$${PLATFORM}/'$(PLATFORM)'/g' \
	    -e 's/$${VERSION}/'$(VERSION)'/g' \
	    -e 's/$${FIREFOX_VER_MIN}/'"$${FIREFOX_VER_MIN:-$(FIREFOX_VER_MIN)}"'/g' \
	    -e 's/$${FIREFOX_VER_MAX}/'"$${FIREFOX_VER_MAX:-$(FIREFOX_VER_MAX)}"'/g' \
	    -e 's/$${THUNDERBIRD_VER_MIN}/'"$${THUNDERBIRD_VER_MIN:-$(THUNDERBIRD_VER_MIN)}"'/g' \
	    -e 's/$${THUNDERBIRD_VER_MAX}/'"$${THUNDERBIRD_VER_MAX:-$(THUNDERBIRD_VER_MAX)}"'/g' \
	    $< > $@

xpi/chrome.manifest: chrome.manifest Makefile
	mkdir -p xpi
	sed -e 's/$${PLATFORM}/'$(PLATFORM)'/g' \
	    $< > $@

$(TARGET): GnomeKeyring.cpp GnomeKeyring.h Makefile
	$(CXX) $< -g -Wall -o $@ \
	    $(XUL_CFLAGS) $(XUL_LDFLAGS) $(GNOME_LDFLAGS) $(GNOME_CFLAGS) $(CPPFLAGS) \
	    $(CXXFLAGS) $(GECKO_DEFINES)
	chmod +x $@

tarball:
	git archive --format=tar \
	    --prefix=$(FULLNAME)/ HEAD \
	    | gzip - > $(ARCHIVENAME).tar.gz

.PHONY: clean-all clean
clean:
	rm -f $(TARGET)
	rm -f $(XPI_TARGET)
	rm -f -r xpi

clean-all: clean
	rm -f *.xpi
	rm -f *.tar.gz

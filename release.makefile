
VERSION := $(shell grep -oPm1 'VERSION=\K.+' stremio.pro)

DEST_DIR := opt/stremio
BUILD_DIR := build
INSTALL_DIR := ${PREFIX}/${DEST_DIR}

ICON_BIN := smartcode-stremio.svg

SERVER_JS := server.js
STREMIO_DESKTOP := smartcode-stremio.desktop

STREMIO_BIN := ${DEST_DIR}/stremio

ALL: ${STREMIO_BIN} ${SERVER_JS}

install:
	install -Dm 755 ${DEST_DIR}/stremio ${INSTALL_DIR}/stremio
	install -Dm 755 ${DEST_DIR}/node ${INSTALL_DIR}/node
	install -Dm 644 ${SERVER_JS} ${INSTALL_DIR}/server.js
	./xdg-icons.sh install images/stremio.svg smartcode-stremio
	xdg-desktop-menu install --mode system ${STREMIO_DESKTOP}
	ln -s ${INSTALL_DIR}/stremio /usr/bin/stremio

uninstall: ${INSTALL_DIR}
	rm -f /usr/bin/stremio
	./xdg-icons.sh uninstall smartcode-stremio
	xdg-desktop-menu uninstall --mode system ${STREMIO_DESKTOP}
	rm -fr ${INSTALL_DIR}

deb:
	checkinstall --default --install=no --fstrans=yes --pkgname stremio --pkgversion 4.4.10 --pkggroup video --pkglicense="MIT" --nodoc --pkgarch=$(dpkg --print-architecture) --requires="libmpv1 \(\>=0.27.2\),qml-module-qt-labs-platform \(\>=5.9.5\),qml-module-qtquick-controls \(\>=5.9.5\),qml-module-qtquick-dialogs \(\>=5.9.5\),qml-module-qtwebchannel \(\>=5.9.5\),qml-module-qtwebengine \(\>=5.9.5\)" make -f release.makefile install

${SERVER_JS}:
	wget "https://s3-eu-west-1.amazonaws.com/stremio-artifacts/four/v${VERSION}/server.js" -qO ${SERVER_JS} || rm ${SERVER_JS}

${STREMIO_BIN}:
	mkdir -p ${BUILD_DIR}
	cd ${BUILD_DIR} && qmake PREFIX=. ..
	make -j -C ${BUILD_DIR}
	make -C ${BUILD_DIR} install

clean:
	rm -rf ${BUILD_DIR} ${DEST_DIR}


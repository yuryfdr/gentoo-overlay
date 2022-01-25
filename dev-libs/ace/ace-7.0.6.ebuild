# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit multilib

DESCRIPTION="The ADAPTIVE Communication Environment - An object oriented network programming toolkit in C++."
HOMEPAGE="https://www.dre.vanderbilt.edu/~schmidt/ACE.html"
SRC_URI="https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-7_0_6/ACE+TAO-7.0.6.tar.bz2"

LICENSE="BSD as-is"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="X +boost +bzip2 +fltk +opengl +qt5 +ssl +stl +tao +threads  +xerces-c +zlib"
# TODO test without tao
# +lzo +wxwidgets

DEPEND="virtual/pkgconfig
	boost? ( dev-libs/boost )
	fltk? ( x11-libs/fltk[opengl] )
	opengl? ( virtual/opengl )
	ssl? ( dev-libs/openssl )
	X? ( x11-libs/libX11 
	     x11-libs/libXt )
	xerces-c? ( dev-libs/xerces-c )
	qt5? ( 
	    dev-qt/qtcore:5
	    dev-qt/qtgui:5 
	    )
	"
#	wxwidgets? ( x11-libs/wxGTK )
#	dev-libs/lzo
#	fox? ( x11-libs/fox:1.7 )
RDEPEND="${DEPEND}"
RESTRICT="mirror"

S="${WORKDIR}/ACE_wrappers"

src_configure() {
	echo '#define ACE_HAS_VERSIONED_NAMESPACE 1' > "${S}"/ace/config.h
	echo '#include "ace/config-linux.h"' >> "${S}"/ace/config.h
	echo 'INSTALL_PREFIX = /usr' > "${S}"/include/makeinclude/platform_macros.GNU
	echo 'INSTALL_LIB = '$(get_libdir) >> "${S}"/include/makeinclude/platform_macros.GNU
	echo 'TCPU=native' >> "${S}"/include/makeinclude/platform_macros.GNU
	echo 'archmodelflag=1 ' >> "${S}"/include/makeinclude/platform_macros.GNU
	echo 'stl=1 ' >> "${S}"/include/makeinclude/platform_macros.GNU
	export ACE_ROOT="${S}"
	export TAO_ROOT="${S}/TAO"
	local myparams
	if use bzip2; then
		myparams="${myparams},bzip2=1"
		echo 'bzip2=1' >> "${S}"/include/makeinclude/platform_macros.GNU
	fi
	#if use lzo; then
	#	myparams="${myparams},lzo1=1"
	#	echo 'lzo1=1' >> "${S}"/include/makeinclude/platform_macros.GNU
	#fi
	if use zlib; then
		myparams="${myparams},zlib=1"
		echo 'zlib=1' >> "${S}"/include/makeinclude/platform_macros.GNU
	fi
	if use boost; then
		myparams="${myparams},boost=1"
		echo 'boost=1' >> "${S}"/include/makeinclude/platform_macros.GNU
	fi
	if use qt5; then
		myparams="${myparams},qt5=1,ace_qt5reactor=1"
		echo 'qt5=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'ace_qt5reactor=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'tao_qtresource=1' >> "${S}"/include/makeinclude/platform_macros.GNU
	fi

	if use fltk; then
		echo 'fl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'gl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},fl=1,gl=1"
	else 
	    if use opengl; then
		echo 'gl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},gl=1"
	    fi
	fi
	#if use wxwidgets; then
	#	echo 'wxWindows=1' >> "${S}"/include/makeinclude/platform_macros.GNU
	#	myparams="${myparams},wxWindows=1"
	#else
	#	myparams="${myparams},wxWindows=0"
	#fi
	
	if use ssl; then
		echo 'ssl=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},ssl=1"
	else
		myparams="${myparams},ssl=0"
	fi

	if use xerces-c; then
		echo 'xerces=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'xerces3=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},xerces=1"
	else
		myparams="${myparams},xerces=0"
	fi

	if use X; then
		echo 'xt=1' >> "${S}"/include/makeinclude/platform_macros.GNU
		myparams="${myparams},xt=1"
	else
		myparams="${myparams},xt=0"
	fi
	echo 'include $(ACE_ROOT)/include/makeinclude/platform_linux.GNU' >> "${S}"/include/makeinclude/platform_macros.GNU

	if use fltk; then
		echo 'PLATFORM_FL_CPPFLAGS=-I/usr/include/fltk' >> "${S}"/include/makeinclude/platform_macros.GNU
		echo 'PLATFORM_FL_LIBS=-L/usr/lib64/fltk -lfltk -lfltk_forms -lfltk_gl' >> "${S}"/include/makeinclude/platform_macros.GNU
	fi
	if use qt5; then
		echo "QTDIR=/usr/"$(get_libdir)"/qt5" >> "${S}"/include/makeinclude/platform_macros.GNU
		echo "MOC=/usr/"$(get_libdir)"/qt5/bin/moc" >> "${S}"/include/makeinclude/platform_macros.GNU
		echo "PLATFORM_QT_CPPFLAGS=-I/usr/include/qt5" >> "${S}"/include/makeinclude/platform_macros.GNU
		echo "CPPFLAGS+=-I/usr/include/qt5" >> "${S}"/include/makeinclude/platform_macros.GNU
		echo "PLATFORM_QT_LDFLAGS=-L/usr/"$(get_libdir)"/" >> "${S}"/include/makeinclude/platform_macros.GNU
	fi
	
	if use tao; then 
	    cd ${TAO_ROOT} 
	    ../bin/mwc.pl -type gnuace -features ${myparams} TAO_ACE.mwc
	else
	    ./bin/mwc.pl -type gnuace -features ${myparams} ACE.mwc
	fi
}

src_compile() {
	export ACE_ROOT="${S}"
	export TAO_ROOT="${S}/TAO"
	export LD_LIBRARY_PATH="${ACE_ROOT}/lib:${LD_LIBRARY_PATH}"
	
	if use tao; then 
	    cd ${TAO_ROOT}
	    emake || die "emake failed"
	else
	    emake || die "emake failed"
	fi
}

src_install() {
	if use tao; then 
	    cd ${TAO_ROOT}
	fi
	default
}

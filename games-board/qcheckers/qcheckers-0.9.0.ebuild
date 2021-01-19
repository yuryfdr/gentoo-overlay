# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit eutils qmake-utils

DESCRIPTION="Qt version of the classic boardgame checkers"
HOMEPAGE="http://qcheckers.sourceforge.net/"
SRC_URI="https://github.com/portnov/qcheckers/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtgui:5
	dev-qt/qtwidgets:5"
RDEPEND=${DEPEND}

src_prepare() {
	default
}

src_configure() {
	eqmake5 PREFIX=/usr 
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "install failed"
}

# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7} )

inherit cmake-utils flag-o-matic python-single-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
# SRC_URI="https://github.com/dreamworksanimation/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
COMMIT="b471f8bc334eb5d85e9078d9506c73af57d02a0a"
SRC_URI="https://github.com/AcademySoftwareFoundation/openvdb/archive/${COMMIT}.tar.gz -> ${P}-b471f8b.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+abi4-compat doc python test libglvnd"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	>=dev-libs/boost-1.67:=[python?,${PYTHON_USEDEP}]
	>=dev-libs/c-blosc-1.5.0
	dev-libs/jemalloc
	dev-libs/log4cplus
	media-libs/glfw:=
	media-libs/openexr:=
	sys-libs/zlib:=
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	libglvnd? ( media-libs/libglvnd )
	python? (
		${PYTHON_DEPS}
		dev-python/numpy[${PYTHON_USEDEP}]
	)"

DEPEND="${RDEPEND}
	dev-cpp/tbb
	virtual/pkgconfig
	doc? ( app-doc/doxygen[latex] )
	test? ( dev-util/cppunit )"

PATCHES=(
	"${FILESDIR}/${P}-use-gnuinstalldirs.patch"
	"${FILESDIR}/${P}-use-pkgconfig-for-ilmbase-and-openexr.patch"
	"${FILESDIR}/${P}-find-boost_python.patch"
	"${FILESDIR}/${P}-boost_numpy.patch"
	"${FILESDIR}/${P}-remesh.patch"
	"${FILESDIR}/boost.patch"
)

S="${WORKDIR}"/${PN}-${COMMIT}

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local myprefix="${EPREFIX}/usr/"

	local mycmakeargs=(
		-DBLOSC_LOCATION="${myprefix}"
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DGLFW3_LOCATION="${myprefix}"
		-DOPENVDB_ABI_VERSION_NUMBER=$(usex abi4-compat 4 5)
		-DOPENVDB_BUILD_DOCS=$(usex doc)
		-DOPENVDB_BUILD_PYTHON_MODULE=$(usex python)
		-DOPENVDB_BUILD_UNITTESTS=$(usex test)
		-DOPENVDB_ENABLE_RPATH=ON
		-DTBB_LOCATION="${myprefix}"
		-DUSE_GLFW3=ON
		-DBoost_PYTHON_LIBRARY="/usr/lib64/libboost_python-3_7.so"
		-DBoost_NUMPY_LIBRARY="/usr/lib64/libboost_numpy-3_7.so"
	)
#		-DPY_OPENVDB_USE_NUMPY=ON
	if use libglvnd; then
		maycmakeargs+=( -DOpenGL_GL_PREFERENCE=GLVND )
	else
		maycmakeargs+=( -DOpenGL_GL_PREFERENCE=LEGACY )
	fi

	use python && mycmakeargs+=( -DPYOPENVDB_INSTALL_DIRECTORY="$(python_get_sitedir)" )
	use test && mycmakeargs+=( -DCPPUNIT_LOCATION="${myprefix}" )

	cmake-utils_src_configure
}

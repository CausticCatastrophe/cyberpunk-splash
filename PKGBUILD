# Maintainer: caustic
pkgname=cyberpunk-wallpaper
pkgver=r0.0
pkgrel=1
pkgdesc='Animated cyberpunk HUD wallpaper for Plasma desktop, lock and login screens, with live system readings'
arch=('any')
url='https://github.com/CausticCatastrophe/cyberpunk-wallpaper'
license=('GPL-2.0-or-later')
depends=('plasma-workspace' 'qt6-declarative')
makedepends=('git')
conflicts=('cyberpunk-splash')
replaces=('cyberpunk-splash')
install=cyberpunk-wallpaper.install
source=("$pkgname::git+$url.git")
sha256sums=('SKIP')

pkgver() {
    cd "$srcdir/$pkgname"
    printf 'r%s.%s' "$(git rev-list --count HEAD)" \
        "$(git rev-parse --short HEAD)"
}

package() {
    local src="$srcdir/$pkgname"
    local wp="$pkgdir/usr/share/plasma/wallpapers/org.cyberpunk.wallpaper"
    local f

    (cd "$src/wallpaper-plugin" && find . -type f -print0) |
        while IFS= read -r -d '' f; do
            install -Dm644 "$src/wallpaper-plugin/$f" "$wp/$f"
        done
}

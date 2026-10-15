# Maintainer: caustic
pkgname=cyberpunk-splash
pkgver=r0.0
pkgrel=1
pkgdesc='Cyberpunk-style Plasma splash with stamped system info'
arch=('any')
url='https://github.com/CausticCatastrophe/cyberpunk-splash'
license=('GPL-2.0-or-later')
depends=('plasma-workspace' 'pacman' 'qt6-declarative')
makedepends=('git')
backup=('etc/cyberpunk-splash.conf')
optdepends=('plymouth: boot splash theme (see cyberpunk-splash-plymouth)'
            'imagemagick: needed by cyberpunk-splash-plymouth to build the boot theme')
install=cyberpunk-splash.install
source=("$pkgname::git+$url.git")
sha256sums=('SKIP')

pkgver() {
    cd "$srcdir/$pkgname"
    printf 'r%s.%s' "$(git rev-list --count HEAD)" \
        "$(git rev-parse --short HEAD)"
}

package() {
    local id=org.cyberpunk.splash
    local src="$srcdir/$pkgname"
    local dest="$pkgdir/usr/share/plasma/look-and-feel/$id"
    local f

    install -Dm644 "$src/theme/metadata.json" "$dest/metadata.json"
    install -Dm644 "$src/theme/contents/splash/Splash.qml" \
        "$dest/contents/splash/Splash.qml"
    install -Dm644 "$src/theme/contents/splash/SystemInfo.qml" \
        "$dest/contents/splash/SystemInfo.qml"

    for f in "$src"/theme/contents/splash/fonts/*; do
        install -Dm644 "$f" "$dest/contents/splash/fonts/${f##*/}"
    done

    for f in "$src"/theme/contents/previews/*; do
        install -Dm644 "$f" "$dest/contents/previews/${f##*/}"
    done

    install -Dm644 "$src/wallpaper/Wallpaper.qml" \
        "$pkgdir/usr/share/cyberpunk-splash/Wallpaper.qml"
    install -Dm755 "$src/wallpaper/render" \
        "$pkgdir/usr/lib/cyberpunk-splash/render-wallpaper"

    install -Dm644 "$src/wallpaper/metadata.json" \
        "$pkgdir/usr/share/wallpapers/CyberpunkSplash/metadata.json"
    install -Dm644 "$src/wallpaper/default.png" \
        "$pkgdir/usr/share/wallpapers/CyberpunkSplash/contents/images/2560x1440.png"

    # boot splash theme builder (Plymouth); optional, run by hand
    install -Dm755 "$src/plymouth/cyberpunk-splash-plymouth" \
        "$pkgdir/usr/bin/cyberpunk-splash-plymouth"

    # animated wallpaper plugin (settings per screen, and for the lock screen)
    local wp="$pkgdir/usr/share/plasma/wallpapers/org.cyberpunk.wallpaper"
    (cd "$src/wallpaper-plugin" && find . -type f -print0) |
        while IFS= read -r -d '' f; do
            install -Dm644 "$src/wallpaper-plugin/$f" "$wp/$f"
        done

    install -Dm755 "$src/cyberpunk-splash-stamp" \
        "$pkgdir/usr/bin/cyberpunk-splash-stamp"
    install -Dm644 "$src/cyberpunk-splash.hook" \
        "$pkgdir/usr/share/libalpm/hooks/cyberpunk-splash.hook"
    install -Dm644 "$src/cyberpunk-splash.conf" \
        "$pkgdir/etc/cyberpunk-splash.conf"
}

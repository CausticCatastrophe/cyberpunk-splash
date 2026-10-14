# Maintainer: caustic
pkgname=cyberpunk-splash
pkgver=1.0
pkgrel=1
pkgdesc='Cyberpunk-style Plasma splash with stamped system info'
arch=('any')
license=('GPL-2.0-or-later')
depends=('plasma-workspace' 'pacman')
backup=('etc/cyberpunk-splash.conf')

package() {
    local id=org.cyberpunk.splash
    local dest="$pkgdir/usr/share/plasma/look-and-feel/$id"

    install -Dm644 "$startdir/theme/metadata.json" "$dest/metadata.json"
    install -Dm644 "$startdir/theme/contents/splash/Splash.qml" \
        "$dest/contents/splash/Splash.qml"
    install -Dm644 "$startdir/theme/contents/splash/SystemInfo.qml" \
        "$dest/contents/splash/SystemInfo.qml"

    local f
    for f in "$startdir"/theme/contents/splash/fonts/*; do
        install -Dm644 "$f" "$dest/contents/splash/fonts/${f##*/}"
    done

    install -Dm755 "$startdir/cyberpunk-splash-stamp" \
        "$pkgdir/usr/bin/cyberpunk-splash-stamp"
    install -Dm644 "$startdir/cyberpunk-splash.hook" \
        "$pkgdir/usr/share/libalpm/hooks/cyberpunk-splash.hook"
    install -Dm644 "$startdir/cyberpunk-splash.conf" \
        "$pkgdir/etc/cyberpunk-splash.conf"
}

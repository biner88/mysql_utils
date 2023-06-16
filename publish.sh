
#/bin/bash
export PUB_HOSTED_URL=https://pub.dev
set https_proxy=127.0.0.1:1082
export https_proxy=http://127.0.0.1:1082 http_proxy=http://127.0.0.1:1082 all_proxy=socks5://127.0.0.1:1082
dart pub publish
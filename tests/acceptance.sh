#!/bin/bash

killall php 2>&- 1>&-s || true
php leproxy.php 127.0.0.1:8180 &
sleep 1

out=$(curl -v --head --silent --fail --proxy http://127.0.0.1:8180 http://reactphp.org 2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1
out=$(curl -v --head --silent --fail --proxy http://127.0.0.1:8180 --location http://github.com 2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1
out=$(curl -v --head --silent --fail --proxy socks5://127.0.0.1:8180 http://reactphp.org 2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1
out=$(curl -v --head --silent --fail --proxy socks4a://127.0.0.1:8180 --location http://github.com  2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1

# unneeded authentication should work
out=$(curl -v --head --silent --fail --proxy http://user:pass@127.0.0.1:8180 http://reactphp.org 2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1
out=$(curl -v --head --silent --fail --proxy socks5://user:pass@127.0.0.1:8180 http://reactphp.org 2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1

# invalid URIs should return error
out=$(curl -v --head --silent --fail --proxy http://127.0.0.1:8180 http://test.invalid/test 2>&1) && echo "FAIL: $out" && exit 1 || echo OK
out=$(curl -v --head --silent --fail --proxy http://127.0.0.1:8180 https://test.invalid/test 2>&1) && echo "FAIL: $out" && exit 1 || echo OK
out=$(curl -v --head --silent --fail --proxy socks://127.0.0.1:8180 http://test.invalid/test 2>&1) && echo "FAIL: $out" && exit 1 || echo OK

# restart LeProxy with authentication required
killall php 2>&- 1>&-s || true
php leproxy.php user:pass@127.0.0.1:8180 &
sleep 1

# authentication should work
out=$(curl -v --head --silent --fail --proxy http://user:pass@127.0.0.1:8180 http://reactphp.org 2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1
out=$(curl -v --head --silent --fail --proxy socks5://user:pass@127.0.0.1:8180 http://reactphp.org 2>&1) && echo OK || (echo "FAIL: $out" && exit 1) || exit 1

# invalid authentication should return error
out=$(curl -v --head --silent --fail --proxy http://127.0.0.1:8180 http://reactphp.org 2>&1) && echo "FAIL: $out" && exit 1 || echo OK
out=$(curl -v --head --silent --fail --proxy socks5://127.0.0.1:8180 http://reactphp.org 2>&1) && echo "FAIL: $out" && exit 1 || echo OK

killall php 2>&- 1>&- || true
echo DONE

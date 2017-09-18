#!/bin/bash

clean_and_exit(){
    # Clean up temp files
    printf 'Cleaning up...'
    rm -rf $TMP_DIR
    printf ' Done.\n\n'
    [ $1 -eq 0 ] && printf '\033[32mJob Finished.\033[m\n' || printf '\033[31mExit with Error code '$1'.\033[m\n'
    exit $1
}

cd /etc/shadowsocks

BASE64_DECODE='base64 -d'
SED_ERES='sed -r'

DNS_IP='127.0.0.1'
DNS_PORT='5300'
IPSET_NAME='ss_spec_gfw'
OUT_FILE='dnsmasq_gfwlist.conf'
OUT_FILE_IPSET='dnsmasq_gfwlist_ipset.conf'

BASE_URL='https://github.com/gfwlist/gfwlist/raw/master/gfwlist.txt'
TMP_DIR=`mktemp -d /tmp/gfwlist2dnsmasq.XXXXXX`
BASE64_FILE="$TMP_DIR/base64.txt"
GFWLIST_FILE="$TMP_DIR/gfwlist.txt"
DOMAIN_FILE="$TMP_DIR/gfwlist2domain.tmp"
GOOGLE_DOMAIN_FILE="$TMP_DIR/google_domain.txt"
OUT_TMP_FILE="$TMP_DIR/gfwlist.tmp"
OUT_TMP_FILE_IPSET="$TMP_DIR/gfwlist.ipset.tmp"

# Fetch GfwList and decode it into plain text
printf '\033[32mJob Started.\n\033[m\n'
printf 'Fetching GfwList...'
curl -s -L $CURL_EXTARG -o$BASE64_FILE $BASE_URL
if [ $? != 0 ]; then
    printf '\033[31m\nFailed to fetch gfwlist.txt. Please check your Internet connection.\033[m\n'
    clean_and_exit 2
fi
$BASE64_DECODE $BASE64_FILE > $GFWLIST_FILE || ( printf '\033[31mFailed to decode gfwlist.txt. Quit.\033[m\n'; clean_and_exit 2 )
printf ' Done.\n\n'

# Convert
IGNORE_PATTERN='^\!|\[|^@@|(https?://){0,1}[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
HEAD_FILTER_PATTERN='s#^(\|\|?)?(https?://)?##g'
TAIL_FILTER_PATTERN='s#/.*$|%2F.*$##g'
DOMAIN_PATTERN='([a-zA-Z0-9][-a-zA-Z0-9]*(\.[a-zA-Z0-9][-a-zA-Z0-9]*)+)'
HANDLE_WILDCARD_PATTERN='s#^(([a-zA-Z0-9]*\*[-a-zA-Z0-9]*)?(\.))?([a-zA-Z0-9][-a-zA-Z0-9]*(\.[a-zA-Z0-9][-a-zA-Z0-9]*)+)(\*)?#\4#g'

echo 'Converting GfwList to '$OUT_TYPE'...'
printf '\033[33m\nWARNING:\nThe following lines in GfwList contain regex, and might be ignored:\033[m\n\n'
cat $GFWLIST_FILE | grep -n '^/.*$'
printf "\033[33m\nThis script will try to convert some of the regex rules. But you should know this may not be a equivalent conversion.\nIf there's regex rules which this script do not deal with, you should add the domain manually to the list.\033[m\n\n"
grep -vE $IGNORE_PATTERN $GFWLIST_FILE | $SED_ERES $HEAD_FILTER_PATTERN | $SED_ERES $TAIL_FILTER_PATTERN | grep -E $DOMAIN_PATTERN | $SED_ERES $HANDLE_WILDCARD_PATTERN > $DOMAIN_FILE

printf 'google.com\ngoogle.ad\ngoogle.ae\ngoogle.com.af\ngoogle.com.ag\ngoogle.com.ai\ngoogle.al\ngoogle.am\ngoogle.co.ao\ngoogle.com.ar\ngoogle.as\ngoogle.at\ngoogle.com.au\ngoogle.az\ngoogle.ba\ngoogle.com.bd\ngoogle.be\ngoogle.bf\ngoogle.bg\ngoogle.com.bh\ngoogle.bi\ngoogle.bj\ngoogle.com.bn\ngoogle.com.bo\ngoogle.com.br\ngoogle.bs\ngoogle.bt\ngoogle.co.bw\ngoogle.by\ngoogle.com.bz\ngoogle.ca\ngoogle.cd\ngoogle.cf\ngoogle.cg\ngoogle.ch\ngoogle.ci\ngoogle.co.ck\ngoogle.cl\ngoogle.cm\ngoogle.cn\ngoogle.com.co\ngoogle.co.cr\ngoogle.com.cu\ngoogle.cv\ngoogle.com.cy\ngoogle.cz\ngoogle.de\ngoogle.dj\ngoogle.dk\ngoogle.dm\ngoogle.com.do\ngoogle.dz\ngoogle.com.ec\ngoogle.ee\ngoogle.com.eg\ngoogle.es\ngoogle.com.et\ngoogle.fi\ngoogle.com.fj\ngoogle.fm\ngoogle.fr\ngoogle.ga\ngoogle.ge\ngoogle.gg\ngoogle.com.gh\ngoogle.com.gi\ngoogle.gl\ngoogle.gm\ngoogle.gp\ngoogle.gr\ngoogle.com.gt\ngoogle.gy\ngoogle.com.hk\ngoogle.hn\ngoogle.hr\ngoogle.ht\ngoogle.hu\ngoogle.co.id\ngoogle.ie\ngoogle.co.il\ngoogle.im\ngoogle.co.in\ngoogle.iq\ngoogle.is\ngoogle.it\ngoogle.je\ngoogle.com.jm\ngoogle.jo\ngoogle.co.jp\ngoogle.co.ke\ngoogle.com.kh\ngoogle.ki\ngoogle.kg\ngoogle.co.kr\ngoogle.com.kw\ngoogle.kz\ngoogle.la\ngoogle.com.lb\ngoogle.li\ngoogle.lk\ngoogle.co.ls\ngoogle.lt\ngoogle.lu\ngoogle.lv\ngoogle.com.ly\ngoogle.co.ma\ngoogle.md\ngoogle.me\ngoogle.mg\ngoogle.mk\ngoogle.ml\ngoogle.com.mm\ngoogle.mn\ngoogle.ms\ngoogle.com.mt\ngoogle.mu\ngoogle.mv\ngoogle.mw\ngoogle.com.mx\ngoogle.com.my\ngoogle.co.mz\ngoogle.com.na\ngoogle.com.nf\ngoogle.com.ng\ngoogle.com.ni\ngoogle.ne\ngoogle.nl\ngoogle.no\ngoogle.com.np\ngoogle.nr\ngoogle.nu\ngoogle.co.nz\ngoogle.com.om\ngoogle.com.pa\ngoogle.com.pe\ngoogle.com.pg\ngoogle.com.ph\ngoogle.com.pk\ngoogle.pl\ngoogle.pn\ngoogle.com.pr\ngoogle.ps\ngoogle.pt\ngoogle.com.py\ngoogle.com.qa\ngoogle.ro\ngoogle.ru\ngoogle.rw\ngoogle.com.sa\ngoogle.com.sb\ngoogle.sc\ngoogle.se\ngoogle.com.sg\ngoogle.sh\ngoogle.si\ngoogle.sk\ngoogle.com.sl\ngoogle.sn\ngoogle.so\ngoogle.sm\ngoogle.sr\ngoogle.st\ngoogle.com.sv\ngoogle.td\ngoogle.tg\ngoogle.co.th\ngoogle.com.tj\ngoogle.tk\ngoogle.tl\ngoogle.tm\ngoogle.tn\ngoogle.to\ngoogle.com.tr\ngoogle.tt\ngoogle.com.tw\ngoogle.co.tz\ngoogle.com.ua\ngoogle.co.ug\ngoogle.co.uk\ngoogle.com.uy\ngoogle.co.uz\ngoogle.com.vc\ngoogle.co.ve\ngoogle.vg\ngoogle.co.vi\ngoogle.com.vn\ngoogle.vu\ngoogle.ws\ngoogle.rs\ngoogle.co.za\ngoogle.co.zm\ngoogle.co.zw\ngoogle.cat\n' >> $DOMAIN_FILE
echo 'Google search domains... Added.'

# Add blogspot domains
printf 'blogspot.ca\nblogspot.co.uk\nblogspot.com\nblogspot.com.ar\nblogspot.com.au\nblogspot.com.br\nblogspot.com.by\nblogspot.com.co\nblogspot.com.cy\nblogspot.com.ee\nblogspot.com.eg\nblogspot.com.es\nblogspot.com.mt\nblogspot.com.ng\nblogspot.com.tr\nblogspot.com.uy\nblogspot.de\nblogspot.gr\nblogspot.in\nblogspot.mx\nblogspot.ch\nblogspot.fr\nblogspot.ie\nblogspot.it\nblogspot.pt\nblogspot.ro\nblogspot.sg\nblogspot.be\nblogspot.no\nblogspot.se\nblogspot.jp\nblogspot.in\nblogspot.ae\nblogspot.al\nblogspot.am\nblogspot.ba\nblogspot.bg\nblogspot.ch\nblogspot.cl\nblogspot.cz\nblogspot.dk\nblogspot.fi\nblogspot.gr\nblogspot.hk\nblogspot.hr\nblogspot.hu\nblogspot.ie\nblogspot.is\nblogspot.kr\nblogspot.li\nblogspot.lt\nblogspot.lu\nblogspot.md\nblogspot.mk\nblogspot.my\nblogspot.nl\nblogspot.no\nblogspot.pe\nblogspot.qa\nblogspot.ro\nblogspot.ru\nblogspot.se\nblogspot.sg\nblogspot.si\nblogspot.sk\nblogspot.sn\nblogspot.tw\nblogspot.ug\nblogspot.cat\n' >> $DOMAIN_FILE
echo 'Blogspot domains... Added.'

# Add twimg.edgesuit.net
printf 'twimg.edgesuit.net\n' >> $DOMAIN_FILE
echo 'twimg.edgesuit.net... Added.'

sort -u $DOMAIN_FILE | $SED_ERES 's#(.+)#server=/\1/'$DNS_IP'\#'$DNS_PORT'#g' > $OUT_TMP_FILE
sort -u $DOMAIN_FILE | $SED_ERES 's#(.+)#ipset=/\1/'$IPSET_NAME'#g' > $OUT_TMP_FILE_IPSET
# Generate output file
cp $OUT_TMP_FILE_IPSET $OUT_FILE_IPSET
cp $OUT_TMP_FILE $OUT_FILE

printf '\nConverting GfwList ... Done.\n\n'

/etc/init.d/dnsmasq restart >/dev/null 2>&1

clean_and_exit 0
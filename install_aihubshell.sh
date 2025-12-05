if [ ! -f /usr/bin/aihubshell ]; then
    echo "Downloading aihubshell.do..."
    sudo wget https://api.aihub.or.kr/api/aihubshell.do -O aihubshell
    sudo cp aihubshell /usr/bin
    sudo chmod +x aihubshell /usr/bin/aihubshell
fi
# aihubshell -help
aihubshell -mode l  |grep 오피스
# aihubshell -mode d -datasetkey 71811 -aihubapikey '87774757-9733-4E76-BEFB-47701AC3808E'
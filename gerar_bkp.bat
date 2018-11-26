docker commit bus marcmir/ambientebkp:1

docker cp bus:/tmp/coletar-temp-sub-flows.sh "c:\Users\MarceloCorreaMiranda\Box Sync\Scripts"
docker cp bus:/tmp/coletar-sub-flows.sh "c:\Users\MarceloCorreaMiranda\Box Sync\Scripts"
docker cp bus:/tmp/coletar-temp-sub-flows.sh "c:\Users\MarceloCorreaMiranda\Box Sync\Scripts"

git init
git add coletar-message-flows.sh coletar-sub-flows.sh coletar-temp-sub-flows.sh
git commit -m "Bkp de arquivos"
git push -u origin master
git status
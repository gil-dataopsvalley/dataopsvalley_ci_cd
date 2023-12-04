export userName=$(gcloud config list account --format "value(core.account)")
export userName=$(cut -d "@" -f1 <<< "$userName")
echo "the user name exec is: "$userName
rm -r -f /home/$userName/projects/dataopsvalley_ci_cd/
cd /home/$userName/projects/
git clone https://github.com/gil-dataopsvalley/dataopsvalley_ci_cd.git
cd dataopsvalley_ci_cd/dbt_ci_cd/
chmod 777 ./create_docker_dgt_govil_dbt.sh
./create_docker_dgt_govil_dbt.sh 



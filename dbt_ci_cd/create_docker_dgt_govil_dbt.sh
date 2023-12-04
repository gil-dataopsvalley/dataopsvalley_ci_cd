#!/bin/bash
# Gcloud #
# gcloud variables
export DiretoryRepo=dataopsvalley_airflow_k8_dbt
echo $DiretoryRepo
# get current project name google-cloud
export ProjectNameGCP=$(gcloud config get-value project) #Example: dgt-gcp-egov-test-govilbi-0
echo $ProjectNameGCP
# name projects exists
export Test_ProjectNameGCP_dataopsvalley=project-dataopsvalley-test
export Prod_ProjectNameGCP_dataopsvalley=project-dataopsvalley-prod # still does not exist
# get user name google-cloud
export userName=$(gcloud config list account --format "value(core.account)")
export userName=$(cut -d "@" -f1 <<< "$userName")
echo "the user name exec is: "$userName


#create folder projects in terminal if not exsit
mkdir -p projects
cd /home/$userName/projects/

# Check the $DiretoryRepo is exists and delete Directory
echo Path: "$PWD"
if [ -d "$DiretoryRepo" ]; then
  echo "$DiretoryRepo does exist."
   rm -rf $DiretoryRepo 
  echo "$DiretoryRepo as deleted."
fi

# Git #
# git - variables
export GitDomain=github.com
export GitUser=gil-dataopsvalley
# git - clone
git clone https://$GitDomain/$GitUser/$DiretoryRepo.git
echo "clone success - https://$GitDomain/$GitUser/$DiretoryRepo.git"
cd $DiretoryRepo/dbt/
# git get version #
cd /home/$userName/projects/$DiretoryRepo
export TagVersion=$(git describe --tags --abbrev=0)
echo 
echo $TagVersion

# get name dbt project
cd /home/$userName/projects/$DiretoryRepo/dbt/
export DbtProjectName=$(ls -d * | head -1)
echo create docker for $DbtProjectName
# get name composer name #
# export test_composer_environmentName=composer-dgt-gcp-egov-test-govilbi-2 #compserName not exist
# export prod_composer_environmentName=composer-dgt-gcp-egov-prod-govilbi-2 #compserName not exist
# export composer_environmentName
# export test_gcs_composer=me-west1-composer-dgt-gcp-e-40315794-bucket
# export prod_gcs_composer=me-west1-composer-dgt-gcp-e-40315794-bucket #change name!!!????
# export gcs_composer #compserName not exist
# export Dag_DBT_Name=dgt_airflow_k8_dbt.py



echo "creator: Gil Kal"

echo $ProjectNameGCP
echo $Test_ProjectNameGCP_dataopsvalley
echo $Prod_ProjectNameGCP
echo DiretoryRepo is: $DiretoryRepo

# Check name $ProjectNameGCP and conig environment Prod or Test
case $ProjectNameGCP in
	$Test_ProjectNameGCP_dataopsvalley)
		echo 1111 "- Test Env - " $ProjectNameGCP
		# export composer_environmentName=$test_composer_environmentName #compserName not exist
		# export gcs_composer=$test_gcs_composer #compserName not exist
		# artifact_registry #
		export ArtifactRegistry=me-west1-docker.pkg.dev
		echo ArtifactRegistry
		export ArtifactRegistryRepo=dataopsvalley-docker-dbt-repo # gcloud artifacts repositories list --project=$ProjectNameGCP --location=me-west1
		echo ArtifactRegistryRepo

   ;;
	$Prod_ProjectNameGCP)
		echo 2222 "- Prod Env - " $ProjectNameGCP
		# export composer_environmentName=$prod_composer_environmentName #compserName not exist
		# export gcs_composer=$prod_gcs_composer #compserName not exist
   ;;
esac

echo "The project name " $ProjectNameGCP # " and composer name: " $composer_environmentName #compserName not exist

######################################
#GCS
# export dag_config_name=config_dgt_airflow_k8_dbt.json
# echo copy Dag file to gcs composer:  $gcs_composer
# gsutil cp -r /home/$userName/projects/$DiretoryRepo/EnvDags/$test_composer_environmentName/dags/* gs://$gcs_composer/dags/

# echo copy config json Dag file to gcs
# export tmp=$(mktemp)
#jq '."TagVersion" = "'"$TagVersion"'"' /home/$userName/projects/$DiretoryRepo/EnvDags/$test_composer_environmentName/dags/$dag_config_name > "$tmp" && mv "$tmp" /home/$userName/projects/$DiretoryRepo/$test_composer_environmentName/dags/$dag_config_name
# jq '."artifact_registry" = "'"$artifact_registry"'"' /home/$userName/projects/$DiretoryRepo/EnvDags/$test_composer_environmentName/dags/$dag_config_name > "$tmp" && mv "$tmp" /home/$userName/projects/$DiretoryRepo/$test_composer_environmentName/dags/$dag_config_name
# jq '."Dbt_project_Name" = "'"$Dbt_project_Name"'"' /home/$userName/projects/$DiretoryRepo/EnvDags/$test_composer_environmentName/dags/$dag_config_name > "$tmp" && mv "$tmp" /home/$userName/projects/$DiretoryRepo/$test_composer_environmentName/dags/$dag_config_name
# gsutil cp /home/$userName/projects/$DiretoryRepo/EnvDags/$test_composer_environmentName/dags/$dag_config_name gs://$gcs_composer/dags/
################################################################################


# me-west1-docker.pkg.dev/project-dataopsvalley-test/dataopsvalley-docker-dbt-repo
# me-west1-docker.pkg.dev/project-dataopsvalley-test/dataopsvalley-docker-dbt-repo/dataopsvalley_airflow_k8_dbt
echo Path: "$PWD"

# Docker #
docker images
# docker build
docker build . -f ./dbt/Dockerfile -t $ArtifactRegistry/$ProjectNameGCP/$ArtifactRegistryRepo/$DbtProjectName:latest
echo docker build success from git repo: $DiretoryRepo
docker images
# docker tag
docker tag \
$ArtifactRegistry/$ProjectNameGCP/$ArtifactRegistryRepo/$DbtProjectName \
$ArtifactRegistry/$ProjectNameGCP/$ArtifactRegistryRepo/$DbtProjectName:$TagVersion
#show docker after build and tag
echo show docker after build and tag
docker images
echo image docker tag is: $TagVersion
         
docker push $ArtifactRegistry/$ProjectNameGCP/$ArtifactRegistryRepo/$DbtProjectName:$TagVersion #//1.1.2
echo push to docker $TagVersion success.
echo path push: $ArtifactRegistry/$ProjectNameGCP/$ArtifactRegistryRepo/$DbtProjectName:$TagVersion       

# gcloud config set project $ProjectNameGCP
# echo Change config project: $ProjectNameGCP


#Composer2
# gcloud composer environments update $composer_environmentName \
#   --location $LOCATION \
#   --update-env-variables=DGT_AIRFLOW_DBT_TAG=$TagVersion
  



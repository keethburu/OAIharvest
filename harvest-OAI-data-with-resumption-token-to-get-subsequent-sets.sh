####################################################################################
####  
#### This script will harvest OAI data from an OAI server and will grab the 
#### appropriate resumptionToken from each returned data-set and will submit
#### the next request using that token, thus maintaining the consistency 
#### across requests.
####

SERVER="http://cdm16998.contentdm.oclc.org/oai/oai.php"

#DCGSETTINGS='--header="From: support@oclc.org" --header="User-Agent: WorldCat Digital Collection Gateway from OCLC.org"'

counter=0
datetime=`date +%F_%H.%M.%S`

touch wget-errors.txt

###############################################
#  create a directory for output data
###############################################

if [ -d output-from-harvest ]
then
     echo "harvest directory already exists.  Renaming to output-from-harvest.$datetime"
     mv output-from-harvest output-from-harvest.$datetime
     mkdir output-from-harvest
else
     mkdir output-from-harvest
     echo "harvest directory created."
fi

###############################################
#  archive this version of script with output
###############################################

cp harvest*.sh output-from-harvest


###############################################
#  harvest data from remote CONTENTdm Server
###############################################


wget "$SERVER?verb=ListRecords&metadataPrefix=oai_dc&set=p16998coll2" $DCGSETTINGS -O oai-output.$counter.txt -o wget-errors-tmp.txt

myResumptionToken=`xmllint --xpath '//*[local-name()="resumptionToken"]/text()' 2>/dev/null oai-output.0.txt`

cat wget-errors-tmp.txt >> wget-errors.txt
rm wget-errors-tmp.txt

mv oai-output.$counter.txt output-from-harvest
let counter=counter+1

echo '========================================================================================'
echo "( 0 )  My Resumption Token:  $myResumptionToken"
echo '========================================================================================'
while [[ $myResumptionToken != "" ]]
do
  wget "$SERVER?verb=ListRecords&resumptionToken=$myResumptionToken" $DCGSETTINGS -O oai-output.$counter.xml -o wget-errors-tmp.txt
  cat wget-errors-tmp.txt >> wget-errors.txt
  rm wget-errors-tmp.txt


  myResumptionToken=`xmllint --xpath '//*[local-name()="resumptionToken"]/text()' 2>/dev/null oai-output.$counter.xml`
  mv oai-output.$counter.xml output-from-harvest
  echo "( $counter )  My Resumption Token:  $myResumptionToken"
  let counter=counter+1


  ##### The following IF loop will add leading ZERO characters to output filenames when
  ##### they reach 10, 100, 1000, 10000.  This allows for better sorting of the files.

  if [ $counter -eq 10 -o $counter -eq 100 -o $counter -eq 1000 -o $counter -eq 10000 ]
  then
      cd output-from-harvest
      for OUTPUTFILES in `ls oai-output*`
      do
          iternum=`echo $OUTPUTFILES|cut -f 2 -d '.' | cut -f 1 -d '.'`
          mv $OUTPUTFILES oai-output.0$iternum.xml
      
      done
      cd ..
  fi  


  echo "========================================================================================"
done

mv wget-errors.txt output-from-harvest



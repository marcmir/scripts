#!/bin/bash
 ############################
 #
 
# Purpose: List backends URLs from IIB
 #  Author: Mauro Junior
 #    Date: 28/May/2018
 #
 ############################
 # Global variables
 ############################
 #set -x
 PATH=${PATH}:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin
 ENVIRONMENT=$1
 ENVIRONMENT=${ENVIRONMENT:-"none"}
 ENVIRONMENT=$(printf ${ENVIRONMENT} | tr [A-Z] [a-z])
 #URL_NEXUS=http://nexus.produbanbr.corp/repository/hub-snapshots/infra/${ENVIRONMENT}_iib-list-backend-urls.txt
 URL_NEXUS=/tmp/coletas/${ENVIRONMENT}_iib-list-backend-urls.txt
 DATE_INFO=$(date +"%F %T")

export PATH ENVIRONMENT URL_NEXUS DATE_INFO

############################
# Function
############################
timestamp (){
	printf "$(date +"%F %T.%N") [PID: $$] -"
}

complementar_subflows (){
 	CHAVE=$1
	
	

	printf "$LINHAFINAL\n" | tee -a /tmp/saida_AllMessageFlowsEndpoints.txt
}
############################
# Main
############################


. /opt/ibm/iib-10.0.0.11/server/bin/mqsiprofile

mqsireportproperties IIBNODE01 -e IIBSERVER01 -o AllMessageFlows -r > /tmp/saida_AllMessageFlows.txt
mqsireportproperties IIBNODE01 -e IIBSERVER01 -o AllSubFlows -r > /tmp/saida_AllSubFlows.txt


sed -i 's/ /+/' /tmp/saida_AllMessageFlows.txt
sed -i 's/ /+/' /tmp/saida_AllSubFlows.txt


#####################################################################
printf "\n\n\n\===== Iniciando Tratamento de subflows =====\n\n\n" 
./coletar-sub-flows.sh

printf "\n\n\n\===== Iniciando Tratamento de Message subflows =====\n\n\n"

CONTA=0
LINHAAPP=0
LINHALABELAPP=10
LINHAMSGFLOW=0
LINHAMSGFLOWLABEL=10
LINHASUBFLOW=0
LINHASUBFLOWNAME=10
LINHASOAPREQUESTNODE=0
LINHASOAPREQUESTNODELABEL=10
LINHASOAPREQUESTNODEURL=10

cat /tmp/saida_AllMessageFlows.txt | grep -v "Handler" | egrep '^Application|+ label=|+ MessageFlow|+   label=|urlSelector=|+   SubFlowNode|+     subflowImplFile=|+     label=|ComIbmSOAPRequestNode|+     webServiceURL=' | while read LINHA 
do
 
	#Application
	if [ $(printf "$LINHA" | grep "^Application" | wc -l) -eq 1 ];
	then
		LINHAAPP=$CONTA
		APPTYPE="Application"
	fi
	
	#Application Label
        if [ $(printf "$LINHA" | grep "label=" | wc -l) -eq 1 ];
        then
                LINHALABELAPP=$(($CONTA-1))
		if [ $LINHALABELAPP -eq $LINHAAPP ];
		then
			APPLABEL=$( printf "$LINHA" | grep "label=" | awk -F "label=" '{print $2}' )
		fi
        fi

        #Message Flow
        if [ $(printf "$LINHA" | grep "+ MessageFlow" | wc -l) -eq 1 ];
        then
		LINHAMSGFLOW=$CONTA
        fi
        

        #Message Flow Label
        if [ $(printf "$LINHA" | grep "+   label=" | wc -l) -eq 1 ];
        then
                LINHAMSGFLOWLABEL=$(($CONTA-1))
		if [ $LINHAMSGFLOWLABEL -eq $LINHAMSGFLOW ];
                then
			MSGFLOWLABEL=$( printf "$LINHA" | grep "label=" | awk -F "label=" '{print $2}' )
			MSGFLOWURLSELECTOR=""
                fi
        fi

        #Message Flow URLSelector
        if [ $(printf "$LINHA" | grep "urlSelector=" | wc -l) -eq 1 ];
        then
                MSGFLOWURLSELECTOR=$( printf "$LINHA" | grep "urlSelector=" | awk -F "urlSelector=" '{print $2}' )
        fi

	#Subflow Node
        if [ $(printf "$LINHA" | grep "+   SubFlowNode" | wc -l) -eq 1 ];
        then
                LINHASUBFLOW=$CONTA
        fi

        #Subflow Name
        if [ $(printf "$LINHA" | grep "+     subflowImplFile=" | wc -l) -eq 1 ];
	then	
                LINHASUBFLOWNAME=$(($CONTA-2))
                if [ $LINHASUBFLOWNAME -eq $LINHASUBFLOW ];
                then
			SUBFLOWNAME=$( printf "$LINHA" | grep "subflowImplFile=" | awk -F "subflowImplFile=" '{print $2}' )
			LINHAFINAL=$(printf "$APPTYPE | $APPLABEL | $MSGFLOWLABEL | $MSGFLOWURLSELECTOR | $SUBFLOWNAME" | sed "s/'//g")
			if [ $(less /tmp/saida_AllMessageFlowsNodes.txt | grep "$LINHAFINAL" | wc -l) -eq 0 ];
			then
				printf "$LINHAFINAL\n" | tee -a /tmp/saida_AllMessageFlowsNodes.txt
			fi
                fi
        fi


  	#SoapRequest Node
        if [ $(printf "$LINHA" | grep "ComIbmSOAPRequestNode" | wc -l) -eq 1 ];
        then
                LINHASOAPREQUESTNODE=$CONTA
        fi

        #SoapRequest Label
        if [ $(printf "$LINHA" | grep "+     label=" | wc -l) -eq 1 ];
        then
                LINHASOAPREQUESTNODELABEL=$(($CONTA-1))
                if [ $LINHASOAPREQUESTNODELABEL -eq $LINHASOAPREQUESTNODE ];
                then
                        REQUESTNODELABEL=$( printf "$LINHA" | grep "label=" | awk -F "label=" '{print $2}' )
                fi
        fi

        #SoapRequest WebserviceURL
        if [ $(printf "$LINHA" | grep "+     webServiceURL=" | wc -l) -eq 1 ];
        then
                LINHASOAPREQUESTNODELABEL=$(($CONTA-2))
                if [ $LINHASOAPREQUESTNODELABEL -eq $LINHASOAPREQUESTNODE ];
                then
                        WEBSERVICEURL=$( printf "$LINHA" | grep "webServiceURL=" | awk -F "webServiceURL=" '{print $2}' )
			LINHAFINAL=$(printf "$APPTYPE | $APPLABEL | $MSGFLOWLABEL | $MSGFLOWURLSELECTOR | $REQUESTNODELABEL | $WEBSERVICEURL" | sed "s/'//g")
			printf "$LINHAFINAL\n" | tee -a /tmp/saida_AllMessageFlowsEndpoints.txt
                fi
        fi        
	

	CONTA=$(($CONTA+1))

done

cat /tmp/saida_AllMessageFlowsEndpoints.txt >> /tmp/saida_iib_backends_urls.txt
cat /tmp/saida_AllMessageFlowsNodes.txt >> /tmp/saida_iib_backends_urls.txt

rm -f /tmp/saida_AllMessageFlowsEndpoints.txt
rm -f /tmp/saida_AllMessageFlowsNodes.txt


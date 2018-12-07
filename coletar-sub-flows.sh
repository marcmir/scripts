#!/bin/bash

############################
# Main
############################


CONTA=0

LINHAAPP=0
LINHAAPPLABEL=10

LINHASUBFLOW=0
LINHASUBFLOWLABEL=10
SUBFLOWANTERIOR=""

LINHASUBFLOWNODE=0
LINHASUBFLOWNODELABEL=10

LINHASOAPREQUESTNODE=0
LINHASOAPREQUESTNODEURL=10

touch /tmp/saida_url_AllSubFlowsNodes.txt
touch /tmp/saida_sub_AllSubFlowsNodes.txt

less /tmp/saida_AllSubFlows.txt | grep -v "Handler" | egrep '^Library|^Application|+ label=|+ Subflow|+   SubFlowNode|+   ComIbmSOAPRequestNode|+   label=|+     subflowImplFile=|+     webServiceURL=' | while read LINHA
do
 
	#Application/Library
	if [ $(printf "$LINHA" | egrep "^Library|^Application" | wc -l) -eq 1 ];
	then
		LINHAAPP=$CONTA
		APPTYPE=$(printf "$LINHA")
	fi
	
	#Application Label
        if [ $(printf "$LINHA" | grep "label=" | wc -l) -eq 1 ];
        then
                LINHAAPPLABEL=$(($CONTA-1))
		if [ $LINHAAPPLABEL -eq $LINHAAPP ];
		then
			APPLABEL=$( printf "$LINHA" | grep "label=" | awk -F "label=" '{print $2}' )
		fi
        fi

	#Subflow
        if [ $(printf "$LINHA" | grep "+ Subflow" | wc -l) -eq 1 ];
        then
                LINHASUBFLOW=$CONTA
        fi
        #SubFlow Label
        if [ $(printf "$LINHA" | grep "+   label=" | wc -l) -eq 1 ];
        then
                LINHASUBFLOWLABEL=$(($CONTA-1))
                if [ $LINHASUBFLOWLABEL -eq $LINHASUBFLOW ];
                then
                        SUBFLOWLABEL=$( printf "$LINHA" | grep "label=" | awk -F "label=" '{print $2}' )
                fi
	fi

	#SoapRequestNode
	if [ $(printf "$LINHA" | grep "+   ComIbmSOAPRequestNode" | wc -l) -eq 1 ];
        then
		LINHASOAPREQUESTNODE=$CONTA
	fi
	#SoapRequestNode URL
	if [ $(printf "$LINHA" | grep "+     webServiceURL=" | wc -l) -eq 1 ];
	then
		LINHASOAPREQUESTNODEURL=$(($CONTA-2))

		if [ $LINHASOAPREQUESTNODEURL -eq $LINHASOAPREQUESTNODE ];
		then
			SOAPREQUESTNODEURL=$( printf "$LINHA" | grep "webServiceURL=" | awk -F "webServiceURL=" '{print $2}' )
			LINHAFINAL=$(printf "$APPTYPE | $APPLABEL | $SUBFLOWLABEL | $SOAPREQUESTNODEURL" | sed "s/'//g")
			if [ $(less /tmp/saida_url_AllSubFlowsNodes.txt | grep "$LINHAFINAL" | wc -l) -eq 0 ];
			then
				printf "$LINHAFINAL\n" | tee -a /tmp/saida_url_AllSubFlowsNodes.txt
			fi
                fi
        fi



        #SubFlowNode
        if [ $(printf "$LINHA" | grep "+   SubFlowNode" | wc -l) -eq 1 ];
        then
		LINHASUBFLOWNODE=$CONTA
        fi
        #SubFlowNode Label
        if [ $(printf "$LINHA" | grep "+     subflowImplFile=" | wc -l) -eq 1 ];
        then
                LINHASUBFLOWNODELABEL=$(($CONTA-2))

		if [ $LINHASUBFLOWNODELABEL -eq $LINHASUBFLOWNODE ];
                then
                        SUBFLOWNODELABEL=$( printf "$LINHA" | grep "subflowImplFile=" | awk -F "subflowImplFile=" '{print $2}' )
			LINHAFINAL=$(printf "$APPTYPE | $APPLABEL | $SUBFLOWLABEL | $SUBFLOWNODELABEL" | sed "s/'//g")
			if [ $(less /tmp/saida_sub_AllSubFlowsNodes.txt | grep "$LINHAFINAL" | wc -l) -eq 0 ];
                        then
				printf "$LINHAFINAL\n" | tee -a /tmp/saida_sub_AllSubFlowsNodes.txt
			fi
                fi
        fi

	CONTA=$(($CONTA+1))

done

echo "\n\n\n\===== Iniciando Tratamento de subflows final =====\n\n\n"
./coletar-temp-sub-flows.sh

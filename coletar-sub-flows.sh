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

        #SoapRequest Label
        if [ $(printf "$LINHA" | grep "+     label=" | wc -l) -eq 1 ];
        then
                LINHASOAPREQUESTNODELABEL=$(($CONTA-1))
                if [ $LINHASOAPREQUESTNODELABEL -eq $LINHASOAPREQUESTNODE ];
                then
                        REQUESTNODELABEL=$( printf "$LINHA" | grep "label=" | awk -F "label=" '{print $2}' )
                fi
        fi

	#SoapRequestNode URL
	if [ $(printf "$LINHA" | grep "+     webServiceURL=" | wc -l) -eq 1 ];
	then
		LINHASOAPREQUESTNODEURL=$(($CONTA-2))
		if [ $LINHASOAPREQUESTNODEURL -eq $LINHASOAPREQUESTNODE ];
		then
			SOAPREQUESTNODEURL=$( printf "$LINHA" | grep "webServiceURL=" | awk -F "webServiceURL=" '{print $2}' )
			
			printf "$APPTYPE | " | sed "s/'//g" | tee -a /tmp/saida_url_AllSubFlowsNodes.txt
			printf "$APPLABEL | " | sed "s/'//g" | tee -a /tmp/saida_url_AllSubFlowsNodes.txt
              		printf "$SUBFLOWLABEL | " | sed "s/'//g" | tee -a /tmp/saida_url_AllSubFlowsNodes.txt
			#printf "$REQUESTNODELABEL | " | tee -a /tmp/saida_url_AllSubFlowsNodes.txt
			printf "$SOAPREQUESTNODEURL\n" | sed "s/'//g" | tee -a /tmp/saida_url_AllSubFlowsNodes.txt
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

			printf "$APPTYPE | " | sed "s/'//g" | tee -a /tmp/saida_sub_AllSubFlowsNodes.txt
                        printf "$APPLABEL | " | sed "s/'//g" | tee -a /tmp/saida_sub_AllSubFlowsNodes.txt
			printf "$SUBFLOWLABEL | " | sed "s/'//g" | tee -a /tmp/saida_sub_AllSubFlowsNodes.txt                        
                       	printf "$SUBFLOWNODELABEL\n" | sed "s/'//g" | tee -a /tmp/saida_sub_AllSubFlowsNodes.txt
                fi
        fi

	CONTA=$(($CONTA+1))

done

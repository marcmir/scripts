#!/bin/bash

############################
# Main
############################

less saida_sub_AllSubFlowsNodes.txt | while read LINHA
do
	APPNAME=$(printf "$LINHA" | awk '{print $3}')
	SUBFLOWNAME=$(printf "$LINHA" | awk '{print $7}')
	SUBFLOWNAME=${SUBFLOWNAME:0:${#SUBFLOWNAME}-8}
	CHAVESUBFLOW=$(printf "$APPNAME | $SUBFLOWNAME")
	NOVALINHA=${LINHA:0:${#LINHA}-8}
	#printf "\n$NOVALINHA"
	printf "\n$NOVALINHA" | tee -a /tmp/saida_temp_AllSubFlowsNodes.txt

	#Varrer todos o nivel 1 de Subflows
	less saida_sub_AllSubFlowsNodes.txt | grep "$CHAVESUBFLOW" | while read REGISTRO
	do
        	SUBFLOWNAME1=$(printf "$REGISTRO" | awk '{print $7}')
        	SUBFLOWNAME1=${SUBFLOWNAME1:0:${#SUBFLOWNAME1}-8}
		CHAVESUBFLOW1=$(printf "$APPNAME | $SUBFLOWNAME1")
		NOVALINHA1=$(printf "$NOVALINHA | $SUBFLOWNAME1")
 		#printf "\n$NOVALINHA1"
		printf "\n$NOVALINHA1" | tee -a /tmp/saida_temp_AllSubFlowsNodes.txt

		#Varrer todos o nivel 2 de Subflows
		less saida_sub_AllSubFlowsNodes.txt | grep "$CHAVESUBFLOW1" | while read REGISTRO2
        	do
                	SUBFLOWNAME2=$(printf "$REGISTRO2" | awk '{print $7}')
                	SUBFLOWNAME2=${SUBFLOWNAME2:0:${#SUBFLOWNAME2}-8}
                	CHAVESUBFLOW2=$(printf "$APPNAME | $SUBFLOWNAME2")
                	NOVALINHA2=$(printf "$NOVALINHA1 | $SUBFLOWNAME2")
			
			#printf "\n$NOVALINHA2"
			printf "\n$NOVALINHA2" | tee -a /tmp/saida_temp_AllSubFlowsNodes.txt
		done
	done

done

echo "\n=== criando arquivo final ====="

touch /tmp/saida_fim_AllSubFlowsNodes.txt

less saida_url_AllSubFlowsNodes.txt | while read LINHA
do
	 printf "\n$LINHA" | tee -a /tmp/saida_fim_AllSubFlowsNodes.txt	
done


less saida_temp_AllSubFlowsNodes.txt | while read LINHA
do
	APPNAME=$(printf "$LINHA" | awk '{print $3}')
	SUBFLOWNAME=$(printf "$LINHA" | awk '{print $NF}')
	CHAVESUBFLOW=$(printf "$APPNAME | $SUBFLOWNAME")

	if [ $(less saida_url_AllSubFlowsNodes.txt | grep "$CHAVESUBFLOW" | wc -l) -eq 1 ];
	then
		REQUESTNODEURL=$(less saida_url_AllSubFlowsNodes.txt | grep "$CHAVESUBFLOW" | awk '{url=$7" | "$NF; print url}' )
		LINHAFINAL=$(printf "$LINHA | $REQUESTNODEURL")	
		

		if [ $(less saida_fim_AllSubFlowsNodes.txt | grep "$LINHAFINAL" | wc -l) -le 1 ];
		then
			printf "\n$LINHA | $REQUESTNODEURL" | tee -a /tmp/saida_fim_AllSubFlowsNodes.txt
		fi

	fi

done

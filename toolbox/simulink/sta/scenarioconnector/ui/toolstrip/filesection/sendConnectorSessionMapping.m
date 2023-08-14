function sendConnectorSessionMapping(inputSpecIDs,jsonStruct,appInstanceID,docSignalMap)



    sendMappingStarted(jsonStruct,appInstanceID);

    msgTopics=Simulink.sta.ScenarioTopics;



    dsStartIdx=ones(1,length(jsonStruct))*-1;
    signalNamesUnderInput=cell(1,length(jsonStruct));


    for kJson=1:length(jsonStruct)

        if strcmp(jsonStruct{kJson}.ParentID,'input')&&strcmp(jsonStruct{kJson}.Type,'DataSet')

            dsStartIdx(kJson)=kJson;
            signalNamesUnderInput{kJson}=jsonStruct{kJson}.Name;
        end


    end




    idxNotUnderInput=dsStartIdx==-1;
    dsStartIdx(idxNotUnderInput)=[];
    signalNamesUnderInput(idxNotUnderInput)=[];
    allDocIDs=[docSignalMap(:).dbid];

    if~isempty(dsStartIdx)&&~isempty(jsonStruct)


        for kSpec=1:length(inputSpecIDs)


            tempSpec=sta.InputSpecification(inputSpecIDs(kSpec));

            isDOCID=allDocIDs==tempSpec.ScenarioDatasetID;



            if any(isDOCID)
                idxSig=find(isDOCID==1,1,'first');

                if idxSig<=length(dsStartIdx)

                    startIdx=dsStartIdx(idxSig);


                    if idxSig==length(dsStartIdx)
                        endIdx=length(jsonStruct);
                    else
                        endIdx=dsStartIdx(idxSig+1)-1;
                    end



                    outMsg=mappingStartup(inputSpecIDs(kSpec),jsonStruct(startIdx:endIdx),false);


                    outMsg.tableviewresults=outMsg.resultsTable;
                    outMsg.inputspecid=outMsg.inputSpecID;

                    xSpec=sta.InputSpecification(outMsg.inputSpecID);
                    xSpec.ScenarioDatasetID=jsonStruct{startIdx}.ID;



                    aRepo=starepository.RepositoryUtility();
                    fileName=getMetaDataByName(aRepo,xSpec.ScenarioDatasetID,'FileName');
                    [~,~,ext]=fileparts(fileName);
                    if any(strcmpi(ext,{'.xlsx','.xls','.csv'}))
                        if isfield(docSignalMap(idxSig),'strongdatatyping')&&...
                            ~isempty(docSignalMap(idxSig).strongdatatyping)
                            if strcmpi(docSignalMap(idxSig).strongdatatyping,'off')
                                outMsg.strongDataType=DAStudio.message('sl_sta_general:common:Off');
                            else
                                outMsg.strongDataType=DAStudio.message('sl_sta_general:common:On');
                            end
                        else






                            outMsg.strongDataType=DAStudio.message('sl_sta_general:common:On');
                        end
                    end


                    outMsg.errorcode=xSpec.ErrorCode;
                    outMsg.comparisonresults=[];
                    outMsg.diagnosticmessage=xSpec.DiagnosticMessage;
                    outMsg.rollup=xSpec.RollUpStatus;
                    mappingMode=xSpec.MappingMode;
                    if strcmpi(mappingMode,'index')||strcmpi(mappingMode,'portorder')
                        mappingModeStr=DAStudio.message('sl_sta:mapping:radioIndex');
                    elseif strcmpi(mappingMode,'blockname')
                        mappingModeStr=DAStudio.message('sl_sta:mapping:radioBlockName');
                    elseif strcmpi(mappingMode,'blockpath')
                        mappingModeStr=DAStudio.message('sl_sta:mapping:radioBlockPath');
                    elseif strcmpi(mappingMode,'custom')
                        mappingModeStr=DAStudio.message('sl_sta:mapping:radioCustom');
                    elseif strcmpi(mappingMode,'signalname')
                        mappingModeStr=DAStudio.message('sl_sta:mapping:radioSignalName');
                    end

                    outMsg.mapmode=mappingModeStr;


                    for k=1:length(outMsg.tableviewresults)

                        tmpStruct.status=outMsg.tableviewresults{k}.status;
                        tmpStruct.portspecific='';
                        tmpStruct.modeldiagnostic=[];
                        tmpStruct.datatype.status=-1;
                        tmpStruct.datatype.diagnosticstext='';
                        tmpStruct.dimension.status=-1;
                        tmpStruct.dimension.diagnosticstext='';
                        tmpStruct.signaltype.status=-1;
                        tmpStruct.signaltype.diagnosticstext='';

                        outMsg.resultsTable{k}.diagnostics=tmpStruct;
                        outMsg.tableviewresults{k}.diagnostics=tmpStruct;
                    end


                    fullChannel=sprintf('%s%s/%s',msgTopics.BASE_MSG,...
                    appInstanceID,msgTopics.SCENARIO_SESSION_MAPPING_RESTORE);

                    message.publish(fullChannel,outMsg);
                end

            end












































        end


    end

    sendMappingComplete(false,appInstanceID);

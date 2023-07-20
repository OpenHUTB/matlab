function[cellOfStructs,props,inputSpecIDs,threwErrDlg,errMsg,DID_MAP]=cb_mapscenarios(...
    modelName,mappingMode,scenarioIDs,compile,strongDataTyping,allowPartial,customFileName,inputSpecIDs,saveSessionID,appID,channelBase)




    cellOfStructs={};
    props.dataProps=[];
    props.inportProps=[];

    DID_MAP=false;


    subChannel='sta/mainui/diagnostic/request';
    fullChannel=sprintf('%s%s/%s',channelBase,appID,subChannel);
    errMsg='';

    if isempty(modelName)||~ischar(modelName)

        slwebwidgets.errordlgweb(fullChannel,...
        'sl_inputmap:inputmap:modelNotOpenTitle',...
        DAStudio.message('sl_inputmap:inputmap:modelNotOpen'));
        threwErrDlg=true;
        errMsg=DAStudio.message('sl_inputmap:inputmap:modelNotOpen');
        return;
    end


    [~,modelName,~]=fileparts(modelName);


    if~bdIsLoaded(modelName)

        slwebwidgets.errordlgweb(fullChannel,...
        'sl_inputmap:inputmap:modelNotOpenTitle',...
        DAStudio.message('sl_inputmap:inputmap:modelNotOpen'));
        threwErrDlg=true;
        errMsg=DAStudio.message('sl_inputmap:inputmap:modelNotOpen');
        return;
    end



    cs=getActiveConfigSet(modelName);


    NUM_SCENARIOS=length(scenarioIDs);

    if~iscell(inputSpecIDs)

        tempIds=inputSpecIDs;
        inputSpecIDs={};

        if~isempty(tempIds)
            for k=1:length(tempIds)

                if isstruct(tempIds(k))||(tempIds(k)==-1)
                    inputSpecIDs{k}=[];
                else
                    inputSpecIDs{k}=tempIds(k);
                end
            end
        else
            inputSpecIDs=cell(1,NUM_SCENARIOS);
        end

    else


        idxStruct=cellfun(@isstruct,inputSpecIDs);
        inputSpecIDs{idxStruct}=[];

    end


    repoMgr=sta.RepositoryManager;

    aSLBuildUtility=Simulink.inputmap.util.SimulinkBuildUtility;
    aSLBuildUtility.FORCE_MODEL_TERMINATION=false;

    cacheStr=get_param(modelName,'ExternalInput');
    cacheLoadExt=get_param(modelName,'LoadExternalInput');
    cacheDirty=get_param(modelName,'Dirty');


    cacheSimulationMode=get_param(modelName,'SimulationMode');
    set_param(modelName,'SimulationMode','normal');


    oldWarnStatus=warning('off','Simulink:Engine:SFcnAPITerminationDeferred');
    oldWarnStatus_AlreadyCompiled=warning('off','Simulink:Engine:ModelAlreadyCompiled');

    for k=1:NUM_SCENARIOS


        [cellOfStructs,props,inputSpecIDs{k},threwErrDlg,errMsg]=cb_mapbutton(...
        modelName,mappingMode,scenarioIDs(k),compile,strongDataTyping,allowPartial,customFileName,...
        inputSpecIDs{k},[num2str(scenarioIDs(k)),'-',appID],false,false,false,saveSessionID,aSLBuildUtility);

        if isempty(inputSpecIDs{k})&&threwErrDlg
            inSpec=sta.InputSpecification();
            inputSpecIDs{k}=inSpec.ID;
        else
            inSpec=sta.InputSpecification(inputSpecIDs{k});
        end

        inSpec.ScenarioDatasetID=scenarioIDs(k);


        msgOut=[];
        msgOut.inputspecid=inputSpecIDs{k};
        msgOut.tableviewresults=cellOfStructs;
        msgOut.comparisonresults=props;
        msgOut.errorcode=false;
        msgOut.diagnosticmessage='';
        msgOut.scenarioid=scenarioIDs(k);

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

        msgOut.mapmode=mappingModeStr;

        aRepo=starepository.RepositoryUtility();
        fileName=getMetaDataByName(aRepo,scenarioIDs(k),'FileName');
        [~,~,ext]=fileparts(fileName);
        if any(strcmpi(ext,{'.xlsx','.xls','.csv'}))
            if strongDataTyping
                aRepo.setMetaDataByName(scenarioIDs(k),'StrongDataTyping','On');
                msgOut.strongDataType=DAStudio.message('sl_sta_general:common:On');
            else
                aRepo.setMetaDataByName(scenarioIDs(k),'StrongDataTyping','Off');
                msgOut.strongDataType=DAStudio.message('sl_sta_general:common:Off');
            end
        end


        if threwErrDlg
            msgOut.errorcode=1;
            msgOut.rollup=-1;
        else

            msgOut.rollup=1;


            if~isempty(msgOut.tableviewresults)


                for kCompare=1:length(msgOut.tableviewresults)


                    if~isempty(msgOut.tableviewresults{kCompare})


                        if~(msgOut.tableviewresults{kCompare}.status)||msgOut.tableviewresults{kCompare}.status~=1


                            switch msgOut.tableviewresults{kCompare}.status

                            case 2
                                if msgOut.rollup~=0
                                    msgOut.rollup=2;
                                end
                            otherwise
                                msgOut.rollup=0;
                                break;
                            end


                        end
                    else

                        msgOut.rollup=0;
                        break;
                    end
                end
            end
        end

        msgOut.diagnosticmessage=errMsg;


        inSpecMapped=sta.InputSpecification(inputSpecIDs{k});
        inSpecMapped.ErrorCode=msgOut.errorcode;
        inSpecMapped.RollUpStatus=msgOut.rollup;

        if~isempty(errMsg)
            inSpecMapped.DiagnosticMessage=errMsg;
        else
            inSpecMapped.DiagnosticMessage='';
        end



        repoUtil=starepository.RepositoryUtility();
        varName=repoUtil.getVariableName(scenarioIDs(k));

        if isempty(varName)
            varName='';
        end

        inSpecMapped.SimulationInput=varName;

        msgTopics=Simulink.sta.ScenarioTopics;


        fullChannel=sprintf('%s%s/%s',...
        channelBase,...
        appID,...
        msgTopics.SCENARIO_MAP_RESULTS);


        message.publish(fullChannel,msgOut);
    end

    for k=1:aSLBuildUtility.COMPILE_COUNT
        eval([modelName,'([],[],[],''term'')']);
    end

    if compile

        if isa(cs,'Simulink.ConfigSetRef')

            cs=getRefConfigSet(cs);
            set_param(cs,'ExternalInput',cacheStr);
            set_param(cs,'LoadExternalInput',cacheLoadExt);
        else
            set_param(modelName,'ExternalInput',cacheStr);
            set_param(modelName,'LoadExternalInput',cacheLoadExt);
            set_param(modelName,'Dirty',cacheDirty);
            set_param(modelName,'SimulationMode',cacheSimulationMode);
        end

    end


    warning(oldWarnStatus.state,'Simulink:Engine:SFcnAPITerminationDeferred');
    warning(oldWarnStatus_AlreadyCompiled.state,'Simulink:Engine:ModelAlreadyCompiled');

    DID_MAP=true;

    fullChannelCompleted=sprintf('%s%s/%s',...
    channelBase,...
    appID,...
    'mappingCompleted');
    msgOutComplete.status=1;
    msgOutComplete.DID_MAP=DID_MAP;
    message.publish(fullChannelCompleted,msgOutComplete);


end

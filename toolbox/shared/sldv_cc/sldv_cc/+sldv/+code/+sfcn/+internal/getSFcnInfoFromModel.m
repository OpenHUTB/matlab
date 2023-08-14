function[out,warningMessages]=getSFcnInfoFromModel(modelName,sfunctionName,getValues,productName,compileModel)





    if nargin<2
        sfunctionName='';
    end

    if nargin<3
        getValues=true;
    end

    if nargin<4
        productName='';
    end

    if nargin<5
        compileModel=true;
    end

    warningMessages=struct('Handle',{},...
    'Id',{},...
    'Message',{});

    ignoredSFunctions={'customAVTBlockSFcn'};

    out=sldv.code.sfcn.SFunctionAnalyzer();


    modelName=get_param(modelName,'Name');
    out.ModelName=modelName;




    if isempty(sfunctionName)
        blks=find_system(modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'BlockType','S-Function');
    else
        blks=find_system(modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'BlockType','S-Function',...
        'FunctionName',sfunctionName);
    end


    analysisRequired=false;
    for kk=1:numel(blks)
        try
            sfcnName=get_param(blks{kk},'FunctionName');
            if sldv.code.sfcn.isSFcnCompatible(sfcnName)
                analysisRequired=true;
            end
        catch
        end
    end

    if~analysisRequired
        return
    end

    Me=[];

    systemsBefore=find_system('type','block_diagram');

    try
        warningMessages=analyzeFcns(out,warningMessages,modelName,blks,...
        ignoredSFunctions,getValues,productName,compileModel);
    catch Me
        if sldv.code.internal.feature('disableErrorRecovery',true)
            rethrow(Me);
        end
    end

    if compileModel
        systemsAfter=find_system('type','block_diagram');
        systemsToClose=setdiff(systemsAfter,systemsBefore);
        if~isempty(systemsToClose)
            for sysCount=1:numel(systemsToClose)
                try


                    set_param(systemsToClose{sysCount},'CloseFcn','');
                catch ME
                    if sldv.code.internal.feature('disableErrorRecovery',true)
                        rethrow(ME);
                    end
                end
            end
            close_system(systemsToClose,0);
        end
    end

    if~isempty(Me)
        Me.rethrow();
    end


    function warningMessages=analyzeFcns(out,warningMessages,modelName,blks,ignoredSFunctions,getValues,productName,compileModel)

        if compileModel
            warnStruct=warning;
            restoreWarnings=onCleanup(@()warning(warnStruct));
            warning('off');



            oldFeatureValue=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
            restoreFeature=onCleanup(@()slfeature('EngineInterface',oldFeatureValue));
            if~strcmpi(get_param(modelName,'SimulationStatus'),'initializing')

                evalc('feval(modelName, [],[], [], ''compile'')');
                compileCleanup=onCleanup(@()terminateModel(modelName));
            end
            warning(warnStruct);
        end

        for kk=1:numel(blks)
            blkH=blks{kk};
            try
                sfcnName=get_param(blkH,'FunctionName');

                if~any(strcmp(ignoredSFunctions,sfcnName))
                    checksum=sldv.code.sfcn.getSFcnChecksum(sfcnName);
                    if~isempty(checksum)
                        instanceInfo=sldv.code.sfcn.SFunctionInstanceInfo(checksum);
                        instanceInfo.setInstanceIdFromHandle(blkH);

                        obj=get_param(blkH,'Object');
                        rtObj=obj.RuntimeObject;
                        if numel(rtObj)~=1

                            blockName=get_param(blkH,'Name');
                            blockHandle=get_param(blkH,'Handle');
                            msgString=sldv.code.internal.getMessageString(productName,...
                            'sldv_sfcn:sldv_sfcn:sfcnBusPropagationError',...
                            blockName);
                            warningMessages(end+1)=struct('Handle',blockHandle,...
                            'Id','sldv_sfcn:sfcnBusPropagationError',...
                            'Message',msgString);%#ok;
                        else
                            instanceInfo.setPortsFromRuntimeObject(obj.RuntimeObject,getValues);
                            out.addInstance(sfcnName,instanceInfo);
                        end
                    end
                end
            catch

                blockHandle=get_param(blkH,'Handle');
                blockName=get_param(blkH,'Name');

                msgString=sldv.code.internal.getMessageString(productName,...
                'sldv_sfcn:sldv_sfcn:sfcnUnsupportedElementError',...
                blockName);
                warningMessages(end+1)=struct('Handle',blockHandle,...
                'Id','sldv_sfcn:sfcnUnsupportedElementError',...
                'Message',msgString);%#ok;
            end
        end


        function terminateModel(modelName)
            warnStruct=warning;
            restoreWarnings=onCleanup(@()warning(warnStruct));

            warning('off');
            cmd=sprintf('feval(''%s'', [],[], [], ''term'')',modelName);
            evalc(cmd);



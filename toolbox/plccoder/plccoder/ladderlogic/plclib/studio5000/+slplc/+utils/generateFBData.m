function generateFBData(sysBlock)




    if~isempty(slplc.utils.getParentPOU(sysBlock))
        return
    end

    stdFBs=plc_find_system(sysBlock,'LookUnderMasks','all','FollowLinks','on','PLCPOUType','stdFB');
    stdFBNames={};
    for fbCount=1:numel(stdFBs)
        stdfb=stdFBs{fbCount};
        fbTypeName=slplc.utils.getParam(stdfb,'PLCBlockType');
        if~ismember(fbTypeName,stdFBNames)
            loc_generateStdFBData(fbTypeName);
            stdFBNames{end+1}=fbTypeName;%#ok<AGROW>
        end
    end

    fbPOUs=plc_find_system(sysBlock,'LookUnderMasks','all','FollowLinks','on','PLCPOUType','Function Block');
    fbPOUNames={};
    if~isempty(fbPOUs)
        depthVec=getBlockDepthVec(fbPOUs);
        [~,sordIdx]=sort(depthVec,'descend');
        fbPOUs=fbPOUs(sordIdx);
        for fbCount=1:numel(fbPOUs)
            fb=fbPOUs{fbCount};
            fbTypeName=slplc.utils.getParam(fb,'PLCPOUName');
            if~ismember(fbTypeName,fbPOUNames)
                loc_generateFBData(fb,fbTypeName);
                fbPOUNames{end+1}=fbTypeName;%#ok<AGROW>
            else
                childFBPOUs=plc_find_system(fb,'LookUnderMasks','all','FollowLinks','on','PLCPOUType','Function Block');
                for childFBPOUCount=2:numel(childFBPOUs)
                    childFBTypeName=slplc.utils.getParam(childFBPOUs{childFBPOUCount},'PLCPOUName');
                    if strcmp(childFBTypeName,fbTypeName)
                        plccore.common.plcThrowError('plccoder:plccore:NestedAOINameMatch',fb,childFBPOUs{childFBPOUCount});
                    end
                end
            end
        end
    end
end

function loc_generateStdFBData(pouName)
    objInBWS=evalin('base','whos');
    objNames={};
    if~isempty(objInBWS)
        objNames={objInBWS.name};
    end

    dataObjName=['FB_',pouName];
    typeName=evalin('base',[dataObjName,'.DataType']);
    initDataName=[pouName,'_InitialValue'];

    if ismember(dataObjName,objNames)&&ismember(typeName,objNames)
        if~ismember(initDataName,objNames)
            createFBInitValueInBW(dataObjName,initDataName);
        end
    else
        error('slplc:stdFBdataNotLoaded','The data of standard function block %s is not loaded',pouName);
    end
end

function loc_generateFBData(pouBlock,pouName)

    slplc.utils.updateVariableList(pouBlock);
    varList=slplc.utils.getVariableList(pouBlock);
    if isempty(varList)
        error('slplc:failedToGenerateFBDataType',...
        'failed to generate function block data type for %s that has no variables defined',pouBlock);
    end

    objInBWS=evalin('base','whos');
    objNames={};
    if~isempty(objInBWS)
        objNames={objInBWS.name};
    end

    dataObjName=['FB_',pouName];

    status=evalin('base',['exist(','''',pouName,'''',', ''var'')']);
    if status
        busObj=evalin('base',pouName);
        isFBBusGenerated=isa(busObj,'Simulink.Bus');
    else
        isFBBusGenerated=false;
    end

    if ismember(dataObjName,objNames)
        try
            varListInData=evalin('base',[dataObjName,'.VariableList']);
        catch ME
            error('slplc:failedToOverrideFBData',...
            'failed to generate function block data type %s for %s that has been defined by users. Please delete this data in base workspace and try it again',...
            dataObjName,pouBlock);
        end
        dataObjFields=evalin('base',['fields(',dataObjName,');']);
        if~isequal(varListInData,varList)||~ismember('DataType',dataObjFields)||~ismember('InitialValue',dataObjFields)

            createFBDataInBW(dataObjName,pouBlock,pouName,isFBBusGenerated);
        else
            createFBBusAndInitValueInBW(dataObjName,pouName,isFBBusGenerated);
        end
    else

        createFBDataInBW(dataObjName,pouBlock,pouName,isFBBusGenerated);
    end
end

function createFBDataInBW(dataObjName,pouBlock,pouName,isFBBusGenerated)
    try
        busObjName=pouName;
        initDataName=[pouName,'_InitialValue'];
        evalin('base',sprintf('%s.VariableList = slplc.utils.getVariableList(''%s'');',dataObjName,pouBlock));
        if~isFBBusGenerated
            evalin('base',sprintf('%s = slplc.utils.createFBBus(%s.VariableList);',busObjName,dataObjName));
        end
        evalin('base',sprintf('%s = Simulink.Bus.createMATLABStruct(''%s'');',initDataName,busObjName));
        evalin('base',sprintf('%s = slplc.utils.createFBInitialValue(%s, %s.VariableList);',initDataName,initDataName,dataObjName));
        evalin('base',sprintf('%s.DataType = %s; %s.InitialValue = %s;',dataObjName,busObjName,dataObjName,initDataName));
    catch causeException
        baseException=MException('slplc:failedToCreateFBData',...
        'failed to create function block data type %s for %s in base workspace',...
        dataObjName,pouBlock);
        baseException=addCause(baseException,causeException);
        throw(baseException);
    end
end

function createFBBusAndInitValueInBW(dataObjName,pouName,isFBBusGenerated)
    busObjName=pouName;
    initDataName=[pouName,'_InitialValue'];
    if isFBBusGenerated
        evalin('base',sprintf('%s = %s.InitialValue;',initDataName,dataObjName));
    else
        evalin('base',sprintf('%s = %s.DataType; %s = %s.InitialValue;',busObjName,dataObjName,initDataName,dataObjName));
    end
end

function createFBInitValueInBW(dataObjName,initDataName)
    evalin('base',sprintf('%s = %s.InitialValue;',initDataName,dataObjName));
end

function depthVec=getBlockDepthVec(blks)
    depthVec=zeros(1,numel(blks));
    for blkCount=1:numel(blks)
        depthVec(blkCount)=getBlockDepth(blks{blkCount});
    end
end

function depth=getBlockDepth(blk)
    blkName=getfullname(blk);
    depth=numel(strsplit(blkName,'/'));
end



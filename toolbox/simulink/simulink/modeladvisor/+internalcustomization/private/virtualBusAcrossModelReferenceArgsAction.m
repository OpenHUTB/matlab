function result=virtualBusAcrossModelReferenceArgsAction(taskobj)


    mdladvObj=taskobj.MAObj;
    topModel=mdladvObj.System;

    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
    fixedModels=ModelAdvisor.List();

    checkData=currentCheckObj.ResultData;
    checkData.topModel=topModel;


    allModels=checkData.info.refModels;
    allModels{end+1}=topModel;

    updatedModelInfo.updatedModels={};
    updatedModelInfo.updatedModelBlocks={};
    updatedModelInfo.updatedOutports=containers.Map('keyType','char','ValueType','any');
    for i=1:length(allModels)
        model=allModels{i};
        updatedModelInfo=loc_updateOneModel(model,checkData,updatedModelInfo);
    end

    updatedModelInfo.updatedModels=sort(updatedModelInfo.updatedModels);
    for i=1:length(updatedModelInfo.updatedModels)
        updatedModel=updatedModelInfo.updatedModels{i};
        fixedModels.addItem(updatedModel);
    end


    result=ModelAdvisor.FormatTemplate('ListTemplate');
    result.setSubBar(false);

    statusMessage={};
    statusMessage{end+1}=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_ActionResult'));
    statusMessage{end+1}=fixedModels;

    result.setSubResultStatusText(statusMessage);
    result.setSubResultStatus('pass');

    mdladvObj.setActionResultStatus(true);
    mdladvObj.setActionEnable(false);
end


function updatedModelInfo=loc_updateOneModel(model,checkData,updatedModelInfo)
    isLoaded=ismember(model,find_system('type','block_diagram'));
    load_system(model);

    changed=false;


    isTopModel=strcmp(model,checkData.topModel);
    needsIOFix=ismember(model,checkData.modelsToEdit);

    if(~isTopModel&&needsIOFix)
        [updatedModelInfo,changedIn]=loc_updateInports(model,updatedModelInfo);
        [updatedModelInfo,changedOut]=loc_updateOutports(model,updatedModelInfo);
        changed=changed|changedIn|changedOut;
    end

    [updatedModelInfo,changedModelBlock]=loc_updateModelBlocks(model,updatedModelInfo);
    changed=changed|changedModelBlock;

    save_system(model);

    if(changed)
        updatedModelInfo.updatedModels{end+1}=model;
    end

    if(~isLoaded)
        close_system(model);
    end
end






function[updatedModelInfo,changed]=loc_updateInports(model,updatedModelInfo)
    inports=loc_findRootBlockType(model,'Inport');
    changed=false;

    for inIdx=1:length(inports)
        inport=inports{inIdx};

        if(loc_rootPortIsVirtualBus(inport))
            changed=true;
            set_param(inport,'BusOutputAsStruct','on');
            loc_insertConversionAfterBlock(inport,1);
        end
    end
end









function[updatedModelInfo,changed]=loc_updateOutports(model,updatedModelInfo)
    outports=loc_findRootBlockType(model,'Outport');
    numOutports=length(outports);

    changedPorts=zeros(1,numOutports);

    for outIdx=1:numOutports
        outport=outports{outIdx};

        if(loc_rootPortIsVirtualBus(outport))
            changedPorts(outIdx)=true;
            set_param(outport,'BusOutputAsStruct','on');
        end
    end

    updatedModelInfo.updatedOutports(model)=changedPorts;
    changed=any(changedPorts);
end





function[updatedModelInfo,changedModelBlock]=loc_updateModelBlocks(model,updatedModelInfo)
    changedModelBlock=false;





    [~,modelBlocks]=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
    modelBlocks=cellfun(@loc_getRefBlockForBlock,modelBlocks,'UniformOutput',false);
    modelBlocks=unique(modelBlocks);
    upgradedModelBlocks=updatedModelInfo.updatedModelBlocks;
    modelBlocks=setdiff(modelBlocks,upgradedModelBlocks);

    for modelIdx=1:length(modelBlocks)
        modelBlock=modelBlocks{modelIdx};
        refModel=get_param(modelBlock,'ModelName');

        if(updatedModelInfo.updatedOutports.isKey(refModel))
            refModelUpdatedPorts=updatedModelInfo.updatedOutports(refModel);
        else
            refModelUpdatedPorts=[];
        end
        changedModelBlock=any(refModelUpdatedPorts);

        if(~changedModelBlock)
            continue;
        end

        modelSrc=bdroot(modelBlock);
        modelType=get_param(modelSrc,'BlockDiagramType');
        isLibrary=strcmp(modelType,'library');

        if(isLibrary)
            load_system(modelSrc);
            set_param(modelSrc,'lock','off');
        end

        for outIdx=1:length(refModelUpdatedPorts)
            if(refModelUpdatedPorts(outIdx))
                loc_insertConversionAfterBlock(modelBlock,outIdx);
            end
        end

        if(isLibrary)
            updatedModelInfo.updatedModelBlocks{end+1}=modelBlock;
        end
    end
end






function loc_insertConversionAfterBlock(block,portNum)
    phs=get_param(block,'PortHandles');
    ph=phs.Outport(portNum);
    line=get_param(ph,'Line');

    if(~ishandle(line))
        return;
    end

    dstBlocks=get_param(line,'DstBlockHandle');
    dstPorts=get_param(get_param(line,'DstPortHandle'),'PortNumber');

    [srcSystem,srcPortStr]=loc_getStringForPort(block,portNum);
    sigConv=loc_createSignalConversion(block,portNum);
    sigConvPhs=get_param(sigConv,'PortHandles');
    [sigSystem,sigPortStr]=loc_getStringForPort(sigConv,1);

    [viewers,disconnectedAxes]=loc_disconnectViewers(ph);
    [prmNames,prmVals]=cachePortParameters(ph);

    for dstIdx=1:length(dstBlocks)
        dstBlock=dstBlocks(dstIdx);

        if(iscell(dstPorts))
            dstPort=dstPorts{dstIdx};
        else
            dstPort=dstPorts;
        end

        [dstSystem,dstPortStr]=loc_getStringForPort(dstBlock,dstPort);

        assert(strcmp(srcSystem,sigSystem));
        assert(strcmp(srcSystem,dstSystem));

        delete_line(srcSystem,srcPortStr,dstPortStr);
        add_line(srcSystem,sigPortStr,dstPortStr);
    end

    add_line(srcSystem,srcPortStr,sigPortStr);

    sigConvPh=sigConvPhs.Outport(1);
    loc_reconnectViewers(sigConvPh,viewers,disconnectedAxes);
    restorePortParameters(sigConvPh,prmNames,prmVals);
end






function[disViewers,disAxes]=loc_disconnectViewers(outport)
    try
        [disViewers,disAxes]=Simulink.ModelReference.Conversion.Utilities.disconnectViewers(outport);
    catch e
        disViewers=[];
        disAxes=[];
        warning(e.message);
    end
end




function loc_reconnectViewers(outport,viewers,vAxes)
    try
        Simulink.ModelReference.Conversion.Utilities.connectViewers(outport,viewers,vAxes);
    catch e
        warning(e.message);
    end
end








function sigConv=loc_createSignalConversion(block,portNum)
    blockObj=get_param(block,'Object');
    blockFull=blockObj.getFullName;
    names=regexp(blockFull,'^(?<base>.+)/[^/]+$','names');
    newBlockName=[names.base,'/SignalConversion'];

    sigConv=Simulink.ModelReference.Conversion.SignalConversionBlock.create(block,portNum,newBlockName);
end











function[portSystem,portStr]=loc_getStringForPort(block,port)
    blockObj=get_param(block,'Object');
    blockFull=blockObj.getFullName;
    names=regexp(blockFull,'^(?<base>.+)/(?<block>[^/]+)$','names');
    portSystem=names.base;
    portStr=sprintf('%s/%d',names.block,port);
end






function blocks=loc_findRootBlockType(model,type)
    blocks=find_system(model,'SearchDepth',1,'BlockType',type);
end





function isBus=loc_isDataTypeBus(datatype)
    isBus=regexp(datatype,'^Bus:\s');
end





function isVB=loc_rootPortIsVirtualBus(port)
    datatype=get_param(port,'OutDataTypeStr');
    if(loc_isDataTypeBus(datatype))
        outputAsStruct=get_param(port,'BusOutputAsStruct');
        isVB=strcmp(outputAsStruct,'off');
    else
        isVB=false;
    end
end





function refBlock=loc_getRefBlockForBlock(block)
    refBlock=get_param(block,'ReferenceBlock');
    if(isempty(refBlock))

        refBlock=block;
    end
end
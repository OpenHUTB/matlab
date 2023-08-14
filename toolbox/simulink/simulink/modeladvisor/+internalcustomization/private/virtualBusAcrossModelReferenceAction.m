function result=virtualBusAcrossModelReferenceAction(taskobj)



    mdladvObj=taskobj.MAObj;
    model=mdladvObj.System;

    check=mdladvObj.ActiveCheck();
    checkID=check.getID();

    looper=UpgradeAdvisor.UpgradeLooper();
    checkData=looper.getCheckData(checkID);
    modelInfo=checkData.modelInfo(model);


    loc_updateInports(modelInfo);
    loc_updateOutports(modelInfo);
    checkData=loc_updateModelBlocks(checkData,modelInfo);


    looper.setCheckData(checkID,checkData);


    result=loc_generateResult(mdladvObj);
end


function result=loc_generateResult(mdladvObj)
    result=ModelAdvisor.FormatTemplate('ListTemplate');
    result.setSubBar(false);

    statusMessage={};
    statusMessage{end+1}=DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReference_ActionResult');
    result.setSubResultStatusText(statusMessage);
    result.setSubResultStatus('pass');

    mdladvObj.setActionResultStatus(true);
    mdladvObj.setActionEnable(false);
end





function loc_updateInports(modelInfo)
    inports=modelInfo.inports;
    inportNeedsUpdate=modelInfo.inportNeedsUpdate;

    for inIdx=1:length(inports)
        if(inportNeedsUpdate(inIdx))
            inport=inports{inIdx};
            set_param(inport,'BusOutputAsStruct','on');
            loc_insertConversionAfterBlock(inport,1);
        end
    end
end







function loc_updateOutports(modelInfo)
    outports=modelInfo.outports;
    outportNeedsUpdate=modelInfo.outportNeedsUpdate;

    for outIdx=1:length(outports)
        if(outportNeedsUpdate(outIdx))
            outport=outports{outIdx};
            set_param(outport,'BusOutputAsStruct','on');
        end
    end
end





function checkData=loc_updateModelBlocks(checkData,modelInfo)
    modelBlocks=modelInfo.modelBlocks;
    modelBlockNeedsUpdate=modelInfo.modelBlockNeedsUpdate;

    for modelIdx=1:length(modelBlocks)
        if(modelBlockNeedsUpdate(modelIdx))
            modelBlock=modelBlocks{modelIdx};
            refModel=get_param(modelBlock,'ModelName');
            refModelInfo=checkData.modelInfo(refModel);
            refOutportNeedsUpdate=refModelInfo.outportNeedsUpdate;
            anyUpdates=any(refOutportNeedsUpdate);


            if(~anyUpdates)
                continue;
            end

            modelSrc=bdroot(modelBlock);
            modelType=get_param(modelSrc,'BlockDiagramType');
            isLibrary=strcmp(modelType,'library');

            if(isLibrary)
                load_system(modelSrc);
                set_param(modelSrc,'lock','off')
            end

            for outIdx=1:length(refOutportNeedsUpdate)
                if(refOutportNeedsUpdate(outIdx))
                    loc_insertConversionAfterBlock(modelBlock,outIdx);
                end
            end

            if(isLibrary)
                checkData.upgradedLibraryBlocks(modelBlock)=1;
            end
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
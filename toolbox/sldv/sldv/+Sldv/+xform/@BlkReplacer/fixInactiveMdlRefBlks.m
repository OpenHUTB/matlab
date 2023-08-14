function fixInactiveMdlRefBlks(obj,~)





    if obj.MdlInlinerOnlyMode
        return;
    end

    for imr=1:numel(obj.MdlRefBlksRejectedForReplacement)
        blockInfo=obj.MdlRefBlksRejectedForReplacement{imr};
        replacementInfo=blockInfo.ReplacementInfo;
        if replacementInfo.IsInactiveMdlBlk
            replaceMdlBlk(obj,replacementInfo.BlockToReplaceOriginalPath,...
            blockInfo,replacementInfo.compIOInfo);
        end
    end
end

function replaceMdlBlk(blkReplacer,mdlBlk,blockInfo,compIOInfo)
    Sldv.xform.BlkRepRule.checkLinkStatus(mdlBlk,blockInfo);

    mdlBlkH=get_param(mdlBlk,'Handle');
    blockName=get_param(mdlBlk,'Name');


    variantControl=get_param(mdlBlk,'VariantControl');



    Simulink.BlockDiagram.createSubsystem(mdlBlkH);
    wrapperSubSys=get_param(get_param(mdlBlkH,'Parent'),'handle');
    set_param(wrapperSubSys,'Name',blockName);
    set_param(wrapperSubSys,'VariantControl',variantControl);

    isVariantChoice=Simulink.SubsystemType(get_param(wrapperSubSys,'Parent')).isVariantSubsystem;
    addedCtrlPortBlks=false;
    isWithinStateflow=isSubSysInsideStateflow(wrapperSubSys);
    if isVariantChoice
        addedCtrlPortBlks=addCtrlBlocksToWrapperSubSystem(blkReplacer,mdlBlkH,wrapperSubSys);
    end


    Simulink.internal.vmgr.VMUtils.DeleteConnectedLines(mdlBlkH);
    blkReplacer.deleteBlock(getfullname(mdlBlkH));



    addSignalSpecBlocksToInterface(blkReplacer,wrapperSubSys,blockInfo,compIOInfo,addedCtrlPortBlks);


    addterms(wrapperSubSys);

    if isWithinStateflow&&~isVariantChoice

        Simulink.BlockDiagram.expandSubsystem(wrapperSubSys);
    end
end

function haveCtrlPortBlks=addCtrlBlocksToWrapperSubSystem(blkReplacer,mdlBlkH,wrapperSubSys)
    refMdl=get_param(mdlBlkH,'ModelName');
    [~,~,ssTriggerBlkHs,ssEnableBlkHs,ssFcnCallInHs]=Sldv.utils.getSubSystemPortBlks(refMdl);
    portBlocksToCopy=[ssTriggerBlkHs,ssEnableBlkHs,ssFcnCallInHs];
    haveCtrlPortBlks=~isempty(portBlocksToCopy);
    if haveCtrlPortBlks
        InBlkHs=Sldv.utils.getBlockHandlesForPortsInSubsys(wrapperSubSys);

        inPortSkipCount=length(portBlocksToCopy);
        for idx=1:inPortSkipCount
            blkReplacer.deleteBlock(getfullname(InBlkHs(idx)));
        end
        set_param(wrapperSubSys,'TreatAsAtomicUnit','on');
        wrapperSubSys=getfullname(wrapperSubSys);
        for idx=1:length(portBlocksToCopy)
            portBlk=portBlocksToCopy{idx};
            blkName=get_param(portBlk,'Name');
            blkReplacer.addBlock(portBlk,[wrapperSubSys,'/',blkName]);
        end
    end
end

function addSignalSpecBlocksToInterface(blkReplacer,wrapperSubSys,blockInfo,compIOInfo,addedControlBlks)

    [InBlkHs,OutBlkHs]=Sldv.utils.getBlockHandlesForPortsInSubsys(wrapperSubSys);
    if~addedControlBlks
        inPortSkipCount=getInBlkCountForControlPorts(blockInfo);
        InBlkHs=InBlkHs(inPortSkipCount+1:end);
    end

    for idx=1:length(InBlkHs)
        inBlk=InBlkHs(idx);
        ph=get_param(inBlk,'PortHandles');
        addSpecBlockForPort(blkReplacer,ph.Outport,compIOInfo.Inport{idx},addedControlBlks);
    end

    for idx=1:length(OutBlkHs)
        outBlk=OutBlkHs(idx);
        ph=get_param(outBlk,'PortHandles');
        addSpecBlockForPort(blkReplacer,ph.Inport,compIOInfo.Outport{idx},addedControlBlks);
    end

end

function addSpecBlockForPort(blkReplacer,ph,compiledInfo,makeSampleTimeInherited)
    if isempty(compiledInfo)
        return;
    end
    ownerBlk=get_param(ph,'Parent');
    ownerSubSys=get_param(ownerBlk,'Parent');

    pos=get_param(ph,'Position');
    type=get_param(ph,'PortType');


    dstPath=[ownerSubSys,'/__SLDVSpec'];
    specH=blkReplacer.addBlock('built-in/SignalSpecification',dstPath,...
    'Showname','off',...
    'MakeNameUnique','on');
    specPorts=get_param(specH,'PortHandles');

    if strcmpi(type,'inport')
        specPos=[pos(1)-20,pos(2)-2,pos(1)-10,pos(2)+2];
        set_param(specH,'position',specPos);


        blkReplacer.addLine(ownerSubSys,specPorts.Outport,ph,'autorouting','on');
    else
        specPos=[pos(1)+10,pos(2)-2,pos(1)+20,pos(2)+2];
        set_param(specH,'position',specPos);


        blkReplacer.addLine(ownerSubSys,ph,specPorts.Inport,'autorouting','on');
    end
    applyOrigCompiledAttributes(specH,compiledInfo,makeSampleTimeInherited);
end

function applyOrigCompiledAttributes(specH,compiledInfo,makeSampleTimeInherited)
    fields=fieldnames(compiledInfo);
    if makeSampleTimeInherited
        compiledInfo.SampleTime='-1';
    end
    for idx=1:length(fields)
        val=compiledInfo.(fields{idx});
        if~isempty(val)
            set_param(specH,fields{idx},val);
        end
    end
end

function count=getInBlkCountForControlPorts(blockInfo)



    count=blockInfo.NumOfTriggerports+...
    blockInfo.NumOfEnableports+...
    blockInfo.NumOfFcnCallTriggerports;
end

function yesno=isSubSysInsideStateflow(blockH)
    sid=Simulink.ID.getSID(blockH);
    yesno=length(strsplit(sid,'::'))>1;
end

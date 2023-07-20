


function isInlined=isInlinedBlockObject(blockType,blkHandle)

    isInlined=false;
    if strcmpi(blockType,'S-Function')&&...
        (strcmpi(get_param(blkHandle,'FunctionName'),'fcgen')...
        ||strcmpi(get_param(blkHandle,'FunctionName'),'fcncallgen'))


        ph=get_param(blkHandle,'PortHandles');
        outports=ph.Outport;

        assert(numel(outports)==1);
        actdsts=slci.internal.getActualDst(blkHandle,0);
        numDstBlks=size(actdsts,1);
        if numDstBlks>0




            isInlined=true;
        end
    else

        blkHdl=get_param(blkHandle,'handle');
        if isInlinedSubsystem(blkHdl,blockType)
            isInlined=true;
        end
    end
end


function isInlined=isInlinedSubsystem(blkHdl,blockType)



    blkObj=get_param(blkHdl,'Object');
    if strcmpi(blockType,'SubSystem')
        subSystemType=slci.internal.getSubsystemType(blkObj);
        if isHiddenOrInlinedSubsystem(...
            blkObj)||strcmpi(subSystemType,'Variant')
            isInlined=true;
            return;
        end
    end
    isInlined=false;
end


function flag=isHiddenOrInlinedSubsystem(blkObj)

    flag=false;

    subSystemType=slci.internal.getSubsystemType(blkObj);
    ishiddenOrInlinedSS=...
    (slci.internal.isSynthesized(blkObj)...
    ||strcmpi(blkObj.RTWSystemCode,'Inline'))...
    &&(strcmpi(subSystemType,'Function-call')...
    ||strcmpi(subSystemType,'Atomic')...
    ||strcmpi(subSystemType,'Action'));

    if ishiddenOrInlinedSS
        flag=true;
    elseif slci.internal.isMatlabFunctionBlock(blkObj)
        ph=blkObj.PortHandles;
        isVirtual=strcmpi(blkObj.TreatAsAtomicUnit,'off')&&...
        isempty(ph.Trigger);
        isInlinedOrVirtual=strcmpi(blkObj.RTWSystemCode,'Inline')...
        ||isVirtual;
        flag=isInlinedOrVirtual;
    end

end
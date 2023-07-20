function collectPortAttributesForSSRefBlocks(rMgr)









    blkInfo=rMgr.AllRefBlocksInfo.getSRInsideModel();
    for idx=1:numel(blkInfo)
        if isBlockUnderVariantSubystem(rMgr,blkInfo{idx}.BlockInstance)




            continue;
        end
        SRBlkHandle=getBlockHandleForReducedModel(rMgr,blkInfo{idx}.BlockInstance,blkInfo{idx});
        if SRBlkHandle<0



            continue;
        end


        SRBlk=Simulink.variant.reducer.utils.getBlockPathWithoutNewLines(SRBlkHandle);
        if isKey(rMgr.PortsToAddSigSpec,SRBlk)
            continue;
        end
        srcSidePortsInfo=getSrcSideInfo(rMgr,SRBlk);
        dstSidePortsInfo=getDstSideInfo(rMgr,SRBlk);
        rMgr.PortsToAddSigSpec(SRBlk)=horzcat(srcSidePortsInfo,dstSidePortsInfo);
    end
end

function srcSidePortsInfo=getSrcSideInfo(rMgr,blk)


    ports=get_param(blk,'PortHandles');
    inports=ports.Inport;
    if isempty(inports)
        srcSidePortsInfo=Simulink.variant.reducer.types.VRedPortInfo.empty;
        return;
    end
    nInports=numel(inports);
    srcSidePortsInfo(nInports)=Simulink.variant.reducer.types.VRedPortInfo;
    for idx=1:nInports
        currBlkInputSlPort=inports(idx);
        line=get_param(currBlkInputSlPort,'Line');
        srcPh=get_param(line,'SrcPorthandle');
        ssPortInfo=Simulink.variant.reducer.types.VRedPortInfo;
        ssPortInfo.SrcPortHandle=srcPh;
        ssPortInfo.DstPortHandle=currBlkInputSlPort;
        ssPortInfo.PortAttributes=getPortAttributes(rMgr,blk,currBlkInputSlPort);
        srcSidePortsInfo(idx)=ssPortInfo;
    end
end

function dstSidePortsInfo=getDstSideInfo(rMgr,blk)


    ports=get_param(blk,'PortHandles');
    outports=ports.Outport;
    if isempty(outports)
        dstSidePortsInfo=Simulink.variant.reducer.types.VRedPortInfo.empty;
        return;
    end
    nOutports=numel(outports);
    dstSidePortsInfo(nOutports)=Simulink.variant.reducer.types.VRedPortInfo;
    for idx=1:nOutports
        currBlkOutputSlPort=outports(idx);
        line=get_param(currBlkOutputSlPort,'Line');
        dstPhs=get_param(line,'DstPorthandle');
        ssPortInfo=Simulink.variant.reducer.types.VRedPortInfo;
        ssPortInfo.SrcPortHandle=currBlkOutputSlPort;
        ssPortInfo.DstPortHandle=dstPhs;
        ssPortInfo.PortAttributes=getPortAttributes(rMgr,blk,currBlkOutputSlPort);
        dstSidePortsInfo(idx)=ssPortInfo;
    end
end

function pa=getPortAttributes(rMgr,blk,portHandle)






    portType=get_param(portHandle,'PortType');
    portNumber=get_param(portHandle,'PortNumber')-1;
    portAttributes=rMgr.CompiledPortAttributesMap(blk);
    for idx=1:numel(portAttributes)
        if isequal(portType,portAttributes(idx).PortType)...
            &&isequal(portNumber,portAttributes(idx).PortNumber)
            pa=portAttributes(idx);
            pa.Handle=portHandle;
            return;
        end
    end
    assert(false,'port is not found');
end

function tf=isBlockUnderVariantSubystem(rMgr,blockPath)







    blockHandle=getOriginalModelBlockHandle(rMgr,blockPath);
    if blockHandle<0
        tf=false;
        return;
    end
    parent=get_param(blockHandle,'Parent');
    parentHandle=get_param(parent,'Handle');
    tf=slInternal('isVariantSubsystem',parentHandle);
end

function blockHandle=getOriginalModelBlockHandle(rMgr,blockPath)






    [blkParent,blkRemain]=strtok(blockPath,'/');
    red2orig=containers.Map(rMgr.BDNameRedBDNameMap.values,...
    rMgr.BDNameRedBDNameMap.keys);
    if~isKey(red2orig,blkParent)
        blockHandle=-1.0;
        return;
    end
    origMdl=red2orig(blkParent);
    origMdlBlkPath=[origMdl,blkRemain];
    blockHandle=get_param(origMdlBlkPath,'Handle');
end

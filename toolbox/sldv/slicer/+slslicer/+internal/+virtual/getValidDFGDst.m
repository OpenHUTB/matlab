function dstP=getValidDFGDst(candHandle,ms)


























    dstP=[];

    import slslicer.internal.*
    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    candO=get(candHandle,'Object');
    po=candO.getParent;
    if isa(candO,'Simulink.Outport')&&isa(po,'Simulink.BlockDiagram')&&ms.refMdlToMdlBlk.isKey(po.Handle)
        try
            inInfo=slInternal('getModelReferenceVirtualBusRootPortInformation',candO.Handle);
            candHandle=inInfo.originalBlock;
        catch ex
            if~strcmp(ex.identifier,'Simulink:modelReference:VirtualBusRootIOInfo_InvalidArg')
                throw(ex)
            end

        end
        candHandle=slslicer.internal.virtual.getBoundaryDstForOutport(candHandle,ms);
        candO=get(candHandle,'Object');
        if iscell(candO)
            candO=cell2mat(candO);
        end
    else

    end

    for oindex=1:length(candO)
        currentCandP=candO(oindex);
        allActDst=currentCandP.getActualDst;

        if isempty(allActDst)
            allActSrc=currentCandP.getActualSrc;
            allActSrc=allActSrc(:,1);
            for sindex=1:length(allActSrc)
                tempSrc=allActSrc(sindex);
                tempO=get(tempSrc,'Object');
                allTempDst=tempO.getActualDst;
                allTempDst=allTempDst(:,1);
                [~,extraDst]=getSrcDstPassingBlock(tempSrc,allTempDst,candHandle);
                dstP=[dstP;extraDst(:)];%#ok<AGROW>
            end
        else
            allActDst=allActDst(:,1);
            dstP=[dstP;allActDst];
        end
    end
    dstP=unique(dstP);

    deletedIdx=false(size(dstP));
    for pindex=1:length(dstP)
        currentDstP=dstP(pindex);
        try
            blockOwner=get(currentDstP,'ParentHandle');
        catch ex
            if strcmpi(ex.identifier,'MATLAB:class:InvalidHandle')
                deletedIdx(pindex)=true;
                continue;
            end
        end
        portType=get(currentDstP,'PortType');
        portNumber=get(currentDstP,'PortNumber');
        dstInfo=[getfullname(currentDstP),':',portType,':',num2str(portNumber)];
        blockO=get(blockOwner,'Object');







        if~ms.isPortValidTarget(currentDstP)&&isa(blockO,'Simulink.Outport')&&strcmp(blockO.Parent,ms.model)
            dstP(pindex)=blockOwner;


        end
    end

    dstP(deletedIdx)=[];
    return;

end

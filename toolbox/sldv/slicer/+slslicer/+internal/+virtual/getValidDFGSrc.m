function srcP=getValidDFGSrc(candHandle,ms)





    srcP=[];
    import slslicer.internal.virtual.*
    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    candO=get(candHandle,'Object');
    po=candO.getParent;
    if isempty(po)
        parentName=candO.Parent;
        po=get_param(parentName,'Object');
    end
    if isa(candO,'Simulink.Inport')&&isa(po,'Simulink.BlockDiagram')&&ms.refMdlToMdlBlk.isKey(po.Handle)
        try
            inInfo=slInternal('getModelReferenceVirtualBusRootPortInformation',candO.Handle);
            candHandle=inInfo.originalBlock;
        catch ex
            if~strcmp(ex.identifier,'Simulink:modelReference:VirtualBusRootIOInfo_InvalidArg')
                throw(ex)
            end

        end

        candHandle=slslicer.internal.virtual.getBoundarySrcForInport(candHandle,ms);

        candO=get(candHandle,'Object');
        if iscell(candO)
            candO=cell2mat(candO);
        end
    end


    for oindex=1:length(candO)
        currentCandP=candO(oindex);
        allActSrc=currentCandP.getActualSrc;
        if~isempty(allActSrc)
            allActSrc=allActSrc(:,1);
            srcP=[srcP;allActSrc];%#ok<AGROW>
        end
    end

    srcP=unique(srcP);
    deletedIdx=false(size(srcP));
    extraSrc=[];
    for pindex=1:length(srcP)
        currentSrcP=srcP(pindex);
        try
            blockOwner=get(currentSrcP,'ParentHandle');
        catch ex
            if strcmpi(ex.identifier,'MATLAB:class:InvalidHandle')
                deletedIdx(pindex)=true;
                continue;
            end
        end

        blockO=get(blockOwner,'Object');
        if isa(blockO,'Simulink.ModelReference')
            if blockO.isSynthesized





















                compParent=blockO.getCompiledParent;
                if~isempty(compParent)
                    compPO=get(compParent,'Object');
                    blockPortNumber=get(currentSrcP,'PortNumber');
                    if~isempty(blockO.VirtualBusInportInformation)





                        [~,c2gmap]=...
                        slslicer.internal.virtual.getVirtualBusPortsMappingInRefModel(blockO,'outport');

                        blockPortNumber=c2gmap(blockPortNumber);
                    end
                    compPortHandles=compPO.PortHandles;

                    newSrc=compPortHandles.Outport(blockPortNumber);
                    if ms.isPortValidTarget(newSrc)
                        extraSrc=[extraSrc;newSrc];%#ok<AGROW> %make it column;
                    else

                    end
                else

                end
            else



            end
        else
            portType=get(currentSrcP,'PortType');
            portNumber=get(currentSrcP,'PortNumber');
            srcInfo=[getfullname(currentSrcP),':',portType,':',num2str(portNumber)];
            blockO=get(blockOwner,'Object');







            if~ms.isPortValidTarget(currentSrcP)&&isa(blockO,'Simulink.Inport')
                if strcmp(blockO.Parent,ms.model)

                    srcP(pindex)=currentSrcP;


                else

                    extraSrc=[extraSrc;slslicer.internal.virtual.getValidDFGSrc(blockOwner,ms)];%#ok<AGROW>


                    deletedIdx(pindex)=true;
                end
            else


            end
        end
    end
    srcP(deletedIdx)=[];
    srcP=[srcP;extraSrc];
end

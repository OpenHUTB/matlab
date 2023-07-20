
function[portBlocks,srcP,dstP]=getSegmentInSubsys(slcri,systemobject,portNumber)






    import slslicer.internal.virtual.*
    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    if nargin<3
        portNumber=[];
    end
    portBlocks=[];
    srcP=[];
    dstP=[];
    allblocklist=systemobject.getCompiledBlockList;
    if strcmpi(slcri.direction,'forward')||strcmpi(slcri.direction,'either')
        inportidx=arrayfun(@(x)isa(get(x,'Object'),'Simulink.Inport'),allblocklist);
        allinport=allblocklist(inportidx);
        if~isempty(portNumber)
            filter=arrayfun(@(x)isequal(num2str(portNumber),get(x,'Port')),allinport);
            allinport=allinport(filter);
        end
        portBlocks=[portBlocks,allinport];
        for ipindex=1:length(allinport)
            inporth=allinport(ipindex);
            newDst=slslicer.internal.virtual.getValidDFGDst(inporth,slcri.modelSlicer);
            phs=get(inporth,'PortHandles');
            extraSrc=repmat(phs.Outport,size(newDst));
            srcP=[srcP;extraSrc];
            dstP=[dstP;newDst];
        end
    end
    if strcmpi(slcri.direction,'back')||strcmpi(slcri.direction,'either')
        outportidx=arrayfun(@(x)isa(get(x,'Object'),'Simulink.Outport'),allblocklist);
        alloutport=allblocklist(outportidx);

        if~isempty(portNumber)
            filter=arrayfun(@(x)isequal(num2str(portNumber),get(x,'Port')),alloutport);
            alloutport=alloutport(filter);
        end

        portBlocks=[portBlocks;alloutport];
        for opindex=1:length(alloutport)
            outporth=alloutport(opindex);
            newSrc=slslicer.internal.virtual.getValidDFGSrc(outporth,slcri.modelSlicer);


            phs=get(outporth,'PortHandles');
            extraDst=repmat(phs.Inport,size(newSrc));
            srcP=[srcP;newSrc];
            dstP=[dstP;extraDst];
        end

    end
end

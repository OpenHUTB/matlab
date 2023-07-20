function segHs=getSignalsForSelectedBlocks(blks)




    inPortSegHs=[];
    outPortSegHs=[];
    for i=1:length(blks)
        blk=blks{i};
        portHs=get_param(blk,'PortHandles');


        inPortHs=portHs.Inport;
        for nInPortH=1:length(inPortHs)
            inPortH=inPortHs(nInPortH);


            inPortLine=get(inPortH,'Line');
            if inPortLine==-1
                continue;
            end
            inPortSourcePortH=get(inPortLine,'SrcPortHandle');
            if(inPortSourcePortH==-1||...
                ~strcmpi(get(inPortSourcePortH,'PortType'),'outport'))
                continue;
            end
            inPortSegHs(end+1)=get(inPortH,'Line');%#ok
        end


        outPortHs=portHs.Outport;
        for nOutPortH=1:length(outPortHs)
            outPortH=outPortHs(nOutPortH);
            outPortSegHs(end+1)=get(outPortH,'Line');%#ok
        end
    end
    segHs=[inPortSegHs,outPortSegHs];
end
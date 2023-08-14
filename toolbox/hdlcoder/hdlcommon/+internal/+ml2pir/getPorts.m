function P=getPorts(blk)



    srcPorts=[];
    dstPorts=[];

    portCs=get_param(blk,'PortConnectivity');
    nPorts=get_param(blk,'Ports');

    P.Block=get_param(blk,'handle');
    P.BlockName=get_param(blk,'name');

    for ii=1:nPorts(1)

        port=portCs(ii);
        blocks={};
        port.SrcPort=port.SrcPort+1;
        for jj=1:numel(port.SrcBlock)
            if port.SrcBlock~=-1
                blocks{end+1}=get_param(port.SrcBlock(jj),'name');
            else
                blocks{end+1}='';
            end
        end
        port.SrcBlockName=blocks;
        srcPorts=[srcPorts,port];
    end

    for ii=nPorts(1)+1:nPorts(1)+nPorts(2)

        port=portCs(ii);
        blocks={};
        port.DstPort=port.DstPort+1;
        for jj=1:numel(port.DstBlock)
            if port.DstBlock~=-1
                blocks{end+1}=get_param(port.DstBlock(jj),'name');
            else
                blocks{end+1}='';
            end
        end
        port.DstBlockName=blocks;
        dstPorts=[dstPorts,port];
    end

    if~isempty(srcPorts)
        srcPorts=rmfield(srcPorts,{'Position','DstBlock','DstPort'});
    end
    if~isempty(dstPorts)
        dstPorts=rmfield(dstPorts,{'Position','SrcBlock','SrcPort'});
    end

    P.SrcPorts=srcPorts;
    P.DstPorts=dstPorts;
end

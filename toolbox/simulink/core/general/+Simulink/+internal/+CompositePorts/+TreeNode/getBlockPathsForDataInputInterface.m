function blockPaths=getBlockPathsForDataInputInterface(h)
    blockPaths=cell(0,1);
    if slfeature('CompositePortsAtRoot')==0
        return;
    end
    if~ishandle(h)
        return;
    end

    intf=Simulink.BlockDiagram.Internal.getGraphInterface(h);
    if~isvalid(intf)||isempty(intf)
        return;
    end

    parts=intf.parts;
    if~isvalid(parts)||isempty(parts)
        return;
    end
    inputPart=parts.getByKey(sl.mfzero.interfaceModel.PartType.SIGNAL_IN);
    if isempty(inputPart)
        return;
    end

    portsArray=inputPart.ports.toArray();
    if isempty(portsArray)
        return;
    end

    numPorts=double(portsArray(end).indexOne);

    blockPaths=cell(numPorts,1);
    for thisPort=portsArray
        if thisPort.realizationType~=sl.mfzero.interfaceModel.RealizationType.MONO_IN&&thisPort.realizationType~=sl.mfzero.interfaceModel.RealizationType.BEP_IN
            error('Unexpected port type.');
        end
        thisPortBlocks=thisPort.blocks.toArray();
        thisPortBlocks=arrayfun(@Simulink.BlockDiagram.Internal.getSlBlock,thisPortBlocks);
        if thisPort.realizationType==sl.mfzero.interfaceModel.RealizationType.BEP_IN

            thisPortBlocks=thisPortBlocks(strcmpi(get_param(thisPortBlocks,'IsBusElementPort'),'on'));
        end
        blockPaths{thisPort.indexOne}=getfullname(thisPortBlocks);
    end
end

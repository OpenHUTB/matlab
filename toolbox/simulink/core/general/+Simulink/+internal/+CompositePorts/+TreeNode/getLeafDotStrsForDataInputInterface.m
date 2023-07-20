function dotStrs=getLeafDotStrsForDataInputInterface(h)
    dotStrs=cell(0,1);
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

    dotStrs=cell(numPorts,1);
    for thisPort=portsArray
        if thisPort.realizationType==sl.mfzero.interfaceModel.RealizationType.MONO_IN
            dotStrs{thisPort.indexOne}={};
        elseif thisPort.realizationType==sl.mfzero.interfaceModel.RealizationType.BEP_IN
            if~isvalid(thisPort.tree)||isempty(thisPort.tree)
                error('Invalid tree.');
            end
            leavesOfTree=Simulink.internal.CompositePorts.TreeNode.findLeavesOfTree(thisPort.tree);

            if numel(leavesOfTree)==1&&isempty(leavesOfTree{1})
                leavesOfTree={};
            end
            dotStrs{thisPort.indexOne}=leavesOfTree;
        else
            error('Unexpected port type.');
        end
    end
end

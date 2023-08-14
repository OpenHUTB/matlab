


function setInheritedSampleTimeForPortInExpFcnMdl(portName)
    portHdl=getSimulinkBlockHandle(portName);
    block=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(portHdl);
    port=block.port;
    rootTree=port.tree;
    setInheritedSampleTime_allNodes(rootTree);
end

function setInheritedSampleTime_allNodes(node)
    signalAttrs=node.signalAttrs;
    if(~isempty(signalAttrs)&&~isempty(signalAttrs.sampleTime))
        Simulink.internal.CompositePorts.TreeNode.setSampleTimeCL(node,'');
    end

    parentAttrs=node.parentAttrs;


    if(isempty(parentAttrs)||...
        Simulink.internal.CompositePorts.TreeNode.getVirtuality(node)...
        ==sl.mfzero.treeNode.Virtuality.NON_VIRTUAL)
        return;
    end


    childrenTreeNodes=parentAttrs.children.toArray;
    for i=1:numel(childrenTreeNodes)
        setInheritedSampleTime_allNodes(childrenTreeNodes(i));
    end
end
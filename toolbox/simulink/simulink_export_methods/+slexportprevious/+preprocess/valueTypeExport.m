


function valueTypeExport(obj)

    if~isR2021aOrEarlier(obj.ver)
        return;
    end


    ipb=obj.findBlocksOfType('Inport');
    opb=obj.findBlocksOfType('Outport');
    iopb=[ipb;opb];
    for idx=1:numel(iopb)
        curBlkName=iopb{idx};


        if isequal(get_param(curBlkName,'IsBusElementPort'),'on')

            block=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(get_param(curBlkName,'handle'));
            port=block.port;
            tree=port.tree;
            node=Simulink.internal.CompositePorts.TreeNode.findNode(tree,block.element);
            valueType=Simulink.internal.CompositePorts.TreeNode.getValueType(node);

            if~isempty(valueType)
                Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(node,'Inherit: auto');
            end
        else
            dtStr=get_param(curBlkName,'OutDataTypeStr');
            if startsWith(dtStr,"ValueType:")
                set_param(curBlkName,'OutDataTypeStr','Inherit: auto');
            end
        end
    end


    ssb=obj.findBlocksOfType('SignalSpecification');
    for idx=1:numel(ssb)
        dtStr=get_param(ssb{idx},'OutDataTypeStr');
        if startsWith(dtStr,"ValueType:")
            set_param(ssb{idx},'OutDataTypeStr','Inherit: auto');
        end
    end
end


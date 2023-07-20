function compareBuiltinBlkReplacements(obj)




    busObjectList=...
    get_param(obj.MdlInfo.ModelH,'BackPropagatedBusObjects');
    for idx=1:length(obj.MdlInfo.BuiltinBlksToReplace)
        currentNode=obj.MdlInfo.BuiltinBlksToReplace{idx};
        if currentNode.ReplacementInfo.Replaced
            Sldv.xform.BlkReplacer.compareInOutPorts(currentNode,busObjectList);
        end
    end
end
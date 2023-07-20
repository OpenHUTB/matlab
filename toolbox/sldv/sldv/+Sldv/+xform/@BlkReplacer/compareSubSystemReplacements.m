function compareSubSystemReplacements(obj)




    busObjectList=...
    get_param(obj.MdlInfo.ModelH,'BackPropagatedBusObjects');
    for idx=1:length(obj.MdlInfo.SubSystemsToReplace)
        currentNode=obj.MdlInfo.SubSystemsToReplace{idx};
        if currentNode.ReplacementInfo.Replaced
            Sldv.xform.BlkReplacer.compareInOutPorts(currentNode,busObjectList);
        end
    end
end
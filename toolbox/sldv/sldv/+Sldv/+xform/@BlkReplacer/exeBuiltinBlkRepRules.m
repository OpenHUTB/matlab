function exeBuiltinBlkRepRules(obj)




    busList=Sldv.xform.BlkReplacer.genBusNamesInBaseWorkSpace;

    for idx=1:length(obj.MdlInfo.BuiltinBlksToReplace)
        currentNode=obj.MdlInfo.BuiltinBlksToReplace{idx};
        currentNode.replaceBlock;
        if currentNode.ReplacementInfo.Replaced
            Sldv.xform.BlkReplacer.fixInOutPorts(currentNode,false,busList);


            if(1==slfeature('ObserverSLDV'))
                obj.reconfigObserverMapping(currentNode);
            end
        end
    end

end

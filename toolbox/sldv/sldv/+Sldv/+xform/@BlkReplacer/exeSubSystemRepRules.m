function exeSubSystemRepRules(obj)




    busList=Sldv.xform.BlkReplacer.genBusNamesInBaseWorkSpace;

    for idx=1:length(obj.MdlInfo.SubSystemsToReplace)
        currentNode=obj.MdlInfo.SubSystemsToReplace{idx};
        currentNode.replaceBlock;
        if currentNode.ReplacementInfo.Replaced
            Sldv.xform.BlkReplacer.fixInOutPorts(currentNode,true,busList);


            if(1==slfeature('ObserverSLDV'))
                obj.reconfigObserverMapping(currentNode);
            end
        end
    end

end

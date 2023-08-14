function syntBlkHandles=getSynthesizedIOPortBlks(origBlkHandles)




    syntBlkHandles=[];

    origRootToSyntRootIOBlockMap=slci.internal.getOrigRootToSyntRootIOBlockMap(origBlkHandleslkHandles);
    if~isempty(origRootToSyntRootIOBlockMap)
        syntBlkHandles=cell2mat(origRootToSyntRootIOBlockMap.values);
    end
end


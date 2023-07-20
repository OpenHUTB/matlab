function addBusInterfaceForDTBlocks(zcModel,dtBlks)








    dicBus=containers.Map;
    for idx=1:length(dtBlks)
        blk=dtBlks{idx};
        dicBus(blk.BlockTopicName)=blk.BlockTopicValue;
    end


    busNames=keys(dicBus);
    for idx=1:length(busNames)
        busName=busNames{idx};
        busValue=dicBus(busName);
        zcModel.InterfaceDictionary.addInterface(busName,'SimulinkBus',busValue);
    end
end



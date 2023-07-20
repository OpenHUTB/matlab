function batchUpdateArchPortInterfaces(archPortsToUpdate,slTypeSetForPorts)






    for i=1:numel(archPortsToUpdate)
        systemcomposer.BusObjectManager.SetPortInterface(archPortsToUpdate(i),slTypeSetForPorts{i},true);
    end
end


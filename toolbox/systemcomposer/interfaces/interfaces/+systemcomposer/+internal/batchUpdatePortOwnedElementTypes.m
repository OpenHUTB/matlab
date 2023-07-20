function batchUpdatePortOwnedElementTypes(archPortsToUpdate,elementNamesToUpdate,slTypeSetForPorts)






    for i=1:numel(archPortsToUpdate)
        systemcomposer.AnonymousInterfaceManager.SetInlinedInterfaceElementProperty(...
        archPortsToUpdate(i),elementNamesToUpdate{i},'Type',slTypeSetForPorts{i});
    end
end


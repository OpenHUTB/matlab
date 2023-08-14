function fixUnresolvedPortInterfaces(modelName,portQualifiedPath,action)




    portInterfUsageChecker=systemcomposer.internal.PortInterfaceUsageChecker(modelName);
    archPorts=[];%#ok<*NASGU> 
    if(strcmp(portQualifiedPath,'[]'))
        archPorts=portInterfUsageChecker.getArchPortsAcrossModelHierarchy();
    else
        archPorts=portInterfUsageChecker.getArchPortsFromPortQualifiedNames({portQualifiedPath});
    end
    portInterfUsageChecker.applyAction(archPorts,action);
    delete(portInterfUsageChecker);
end

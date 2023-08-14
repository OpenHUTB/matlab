function isSW=isOnlyMappedToSoftwareNodes(refMdl,topMdl)








    import Simulink.DistributedTarget.internal.NodeMappingType

    mappingType=...
    Simulink.DistributedTarget.internal.checkMappingOfNodes(refMdl,topMdl);

    isSW=false;
    switch(mappingType)
    case NodeMappingType.AllSoftware
        isSW=true;
    case{NodeMappingType.AllHardware,NodeMappingType.MixedHardwareSoftware}
        isSW=false;
    end

end

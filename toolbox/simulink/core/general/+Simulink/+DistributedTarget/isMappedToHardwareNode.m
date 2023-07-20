function isFPGA=isMappedToHardwareNode(refMdl,topMdl)








    import Simulink.DistributedTarget.internal.NodeMappingType

    mappingType=...
    Simulink.DistributedTarget.internal.checkMappingOfNodes(refMdl,topMdl);

    isFPGA=false;
    switch(mappingType)
    case{NodeMappingType.AllSoftware,NodeMappingType.MixedHardwareSoftware}
        isFPGA=false;
    case NodeMappingType.AllHardware
        isFPGA=true;
    end

end

classdef(Hidden,Sealed)VRedPortBusSubsystem<handle




    properties
        SrcPort=[];
        DstPort=[];
        CompiledBusType(1,:)char;
        CompiledBusStruct=[];
        CompiledSignalHierarchy=[];
        OrigBlkCell=[];
    end
end

classdef DataStoreMemoryFixSimpleCaseForSubsystem<Simulink.ModelReference.Conversion.DataStoreMemoryFixSimpleCase
    methods(Access=public)
        function this=DataStoreMemoryFixSimpleCaseForSubsystem(params,subsys,dsmBlock)
            this@Simulink.ModelReference.Conversion.DataStoreMemoryFixSimpleCase(params,subsys,dsmBlock);
        end
    end

    methods(Access=protected)
        function newBlkName=getNewBlockName(~,subsys,dsmBlock)
            newBlkName=[getfullname(subsys),'/',get_param(dsmBlock,'Name')];
        end

        function blk=getParent(~,subsys)
            blk=subsys;
        end
    end
end

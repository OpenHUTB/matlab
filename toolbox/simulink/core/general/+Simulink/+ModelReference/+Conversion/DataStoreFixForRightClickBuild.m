


classdef DataStoreFixForRightClickBuild<Simulink.ModelReference.Conversion.DataStoreMemoryFixSimpleCase
    methods(Access=public)
        function this=DataStoreFixForRightClickBuild(params,subsys,dsmBlock)
            this@Simulink.ModelReference.Conversion.DataStoreMemoryFixSimpleCase(params,subsys,dsmBlock);
        end
    end

    methods(Access=protected)
        function deleteDSMBlock(~,~)
        end
    end
end

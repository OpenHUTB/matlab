classdef(Abstract,Hidden)VRedReferenceBlock<handle






    properties
        OrigName(1,:)char;
        Name(1,:)char;
        FullPath(1,:)char;
        BlksSVCEMap=[];
        BlksAttribsMap=containers.Map;
        NumberOfConfigsActive=[];
        PortsToIgnoreTerm=[];
        VarBlkChoiceInfoStructsVec=Simulink.variant.reducer.types.VRedVariantBlockChoiceInfo.empty;
        CompiledSpecialBlockInfo=Simulink.variant.reducer.types.VRedCompiledSpecialBlockInfo.empty;
        LibRefsDataStructsVec=Simulink.variant.reducer.types.VRedLibRefsData.empty;
    end

    methods
        function delete(obj)
            obj.BlksAttribsMap=containers.Map;
            obj.VarBlkChoiceInfoStructsVec=Simulink.variant.reducer.types.VRedVariantBlockChoiceInfo.empty;
            obj.CompiledSpecialBlockInfo=Simulink.variant.reducer.types.VRedCompiledSpecialBlockInfo.empty;
            obj.LibRefsDataStructsVec=Simulink.variant.reducer.types.VRedLibRefsData.empty;
        end
    end
end

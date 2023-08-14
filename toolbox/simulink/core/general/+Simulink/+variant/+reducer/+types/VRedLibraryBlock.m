classdef(Hidden,Sealed)VRedLibraryBlock<Simulink.variant.reducer.types.VRedReferenceBlock






    properties
        ModelRefsDataStructsVec=Simulink.variant.reducer.types.VRedModelRefsData.empty;
        HierBlksNotUsed=[];
    end

    methods
        function delete(obj)
            obj.ModelRefsDataStructsVec=Simulink.variant.reducer.types.VRedModelRefsData.empty;
        end
    end
end

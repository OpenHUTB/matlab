classdef SpecificationBuilder




    methods(Abstract)
        spec=build(obj)
    end

    methods(Sealed,Access=protected)
        function spec=getDefaultSpec(~)
            spec=struct('exponentsData',struct([]),'skipLayers',{{''}},'quantizedDLNetwork',false);
        end
    end
end


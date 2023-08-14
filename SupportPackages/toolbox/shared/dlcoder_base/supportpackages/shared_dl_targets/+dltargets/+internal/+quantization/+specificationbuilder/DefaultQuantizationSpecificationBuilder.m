classdef DefaultQuantizationSpecificationBuilder<dltargets.internal.quantization.specificationbuilder.SpecificationBuilder





    methods
        function spec=build(obj)
            spec=obj.getDefaultSpec();
            spec.quantizedDLNetwork=true;
        end
    end
end


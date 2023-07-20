classdef NullSpecificationBuilder<dltargets.internal.quantization.specificationbuilder.SpecificationBuilder





    methods
        function spec=build(obj)
            spec=obj.getDefaultSpec();
        end
    end
end



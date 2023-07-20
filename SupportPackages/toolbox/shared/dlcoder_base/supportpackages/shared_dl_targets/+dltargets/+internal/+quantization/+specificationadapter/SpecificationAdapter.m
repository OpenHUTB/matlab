classdef(Abstract)SpecificationAdapter




    properties(SetAccess=private)
Specification
    end

    methods
        function obj=SpecificationAdapter(specification)
            obj.Specification=specification;
        end
    end

    methods(Abstract)
        exponent=getActivationsExponent(this,layerNames);
        exponent=getWeightsExponent(this,layerNames);
        exponent=getBiasExponent(this,layerNames);
        exponent=getParameterExponent(this,layerNames);

        b=hasActivationsValue(this,layerName);
        b=hasParameterValue(this,layerNames);

        this=setSkipLayer(this,layerNames,compKey,compName);
        skipLayers=getSkipLayers(this);
    end
end


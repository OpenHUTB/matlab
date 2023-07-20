classdef(Abstract,Hidden)Instance<handle&matlab.mixin.SetGet&matlab.mixin.Heterogeneous&matlab.mixin.CustomDisplay




    properties(SetAccess=protected)

Root

ParentSystem

        ShortName string

Category

Value

PhysicalValue

        Units string

        FeatureReference string

ValueContainerElement

ParameterSet

InstanceElement

ValueType

PhysicalValueDims

HasGroupedValues
    end

    methods
        function obj=Instance(root,sys,inst)







            obj.Root=root;


            obj.ShortName=asam.cdfx.mf0.getShortName(inst);


            obj.ParentSystem=sys;


            obj.Category=asam.cdfx.mf0.getCategory(inst);


            obj.FeatureReference=asam.cdfx.mf0.getFeatureReference(inst);


            isStructure=strcmpi(obj.Category,"STRUCTURE");


            if obj.hasVariantProps()
                obj.ParameterSet=asam.cdfx.mf0.getVariantProp(inst,1);
            else
                obj.ParameterSet=inst;
            end


            if isStructure
                obj.ValueContainerElement=inst;
            else
                obj.ValueContainerElement=asam.cdfx.mf0.getValueContainer(obj.ParameterSet);
            end


            obj.ValueType=obj.getValueType(obj.ValueContainerElement);


            obj.Units=asam.cdfx.mf0.getUnitDisplayName(obj.ValueContainerElement,isStructure);

        end

    end
    methods
        function hasVariants=hasVariantProps(obj)
            hasVariants=obj.ParentSystem.HasVariantProps;
        end
    end
    methods(Abstract,Hidden)
        setValue(obj,value,isInternalModify)
        valueType=getValueType(obj,valueContainer)

    end
end


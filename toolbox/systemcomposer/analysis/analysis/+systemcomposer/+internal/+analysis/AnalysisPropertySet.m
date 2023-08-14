classdef AnalysisPropertySet<systemcomposer.internal.analysis.AnalysisObject



    properties
        name='';
        propertySet=[];
    end

    methods
        function updated=update(obj,instance)
            updated=false;
        end
    end

    methods
        function obj=AnalysisPropertySet(model)


            obj@systemcomposer.internal.analysis.AnalysisObject(model);
        end

        function setName(obj,name)
            obj.name=name;
        end

        function newSet=clone(obj,model)
            newSet=systemcomposer.internal.analysis.AnalysisPropertySet(model);
            newSet.propertySet=obj.propertySet;
            newSet.name=obj.name;
        end

        function processProperties(obj,definition,model)
            obj.mfObject=definition.createPropertySet(obj.name);
            obj.model=model;
            for p=1:length(obj.propertySet)
                propDef=obj.propertySet(p);
                prop=obj.mfObject.addProperty(propDef.name);
                prop.defaultValue.destroy;
                prop.defaultValue=obj.convertMxArrayToValueSpecification(propDef.value);
                prop.computationScope=propDef.scope;
                prop.type.destroy;
                prop.type=obj.createValueType(propDef.type);

            end
        end

        function addProperty(obj,propertyName,propertyType,value,scope)
            pStruct=struct('name',propertyName,...
            'value',value,...
            'scope',scope,...
            'type',propertyType);
            if isempty(obj.propertySet)
                obj.propertySet=pStruct;
            else
                obj.propertySet(end+1)=pStruct;
            end

        end
    end
end


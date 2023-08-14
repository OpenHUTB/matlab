classdef Structure<asam.cdfx.instance.Instance




    properties

SWInstances
NumInstances
InstanceNames
InstanceValues
    end

    methods
        function obj=Structure(root,sys,inst)



            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            obj.InstanceElement=obj.ParameterSet.SW_INSTANCE.toArray;


            obj.NumInstances=numel(obj.InstanceElement);


            obj.PhysicalValue=obj.getPhysicalValues();
            obj.Value=obj.PhysicalValue;
        end

        function setValue(obj,value,~)




            if~strcmpi(class(value),"containers.Map")
                error(message('asam_cdfx:CDFX:CategoryValueTypeMismatch',obj.Category));
            end

            if~all(size(value)==size(obj.PhysicalValue))
                error(message('asam_cdfx:CDFX:CategoryValueSizeMismatch',obj.Category));
            end


            inputKeys=keys(value);
            objectKeys=keys(obj.PhysicalValue);


            if~isequal(inputKeys,objectKeys)
                error(message('asam_cdfx:CDFX:StructureKeyMismatch',obj.ShortName));
            end


            inputValues=values(value);


            for idx=1:obj.NumInstances
                obj.SWInstances(idx).setValue(inputValues{idx},false);
            end


            obj.PhysicalValue=value;
            obj.Value=obj.PhysicalValue;

        end

        function physVals=getPhysicalValues(obj)





            for idx=1:obj.NumInstances
                obj.SWInstances=[obj.SWInstances,asam.cdfx.SWInstanceFactory(obj.Root,obj.ParentSystem,obj.InstanceElement(idx))];
                obj.InstanceNames=[obj.InstanceNames,obj.SWInstances(idx).ShortName];
                obj.InstanceValues{end+1}=obj.SWInstances(idx).Value;
            end


            physVals=containers.Map(obj.InstanceNames,obj.InstanceValues,'UniformValues',false);
        end

        function valueType=getValueType(obj,valueContainer)

            valueType="";
        end
    end
end


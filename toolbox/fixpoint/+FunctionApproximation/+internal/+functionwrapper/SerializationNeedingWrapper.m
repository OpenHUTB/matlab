classdef(Abstract)SerializationNeedingWrapper<FunctionApproximation.internal.functionwrapper.AbstractWrapper






    properties(SetAccess=protected)
        Data FunctionApproximation.internal.serializabledata.SerializableData
    end

    methods
        modify(this,data);

        function objectToSave=saveobj(this)

            nameSplit=split(class(this),'.');
            objectToSave=struct('data',this.Data,'classname',nameSplit{end});
        end
    end

    methods(Static)
        function this=loadobj(savedObject)

            this=FunctionApproximation.internal.functionwrapper.(savedObject.classname)(savedObject.data);
        end
    end
end

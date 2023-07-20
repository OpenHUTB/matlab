classdef SerializableData<matlab.mixin.Heterogeneous





    properties(SetAccess=private)
        NumberOfDimensions(1,1)double
    end

    properties
InputTypes
OutputType
    end

    methods(Abstract)
        this=update(this,varargin)
    end

    methods(Access=protected)
        function value=numberOfDimensions(this)
            value=numel(this.InputTypes);
        end
    end

    methods
        function value=get.NumberOfDimensions(this)
            value=numberOfDimensions(this);
        end

        function objectToSave=saveobj(this)

            nameSplit=split(class(this),'.');
            objectToSave.classname=nameSplit{end};

            propNames=properties(this);
            for ii=1:numel(propNames)
                structValue.(propNames{ii})=this.(propNames{ii});
            end
            objectToSave.structValue=structValue;
        end

        function interfaceTypes=getInterfaceTypes(this)



            interfaceTypes=[this.InputTypes,this.OutputType];
        end
    end

    methods(Static)
        function this=loadobj(savedObject)

            this=FunctionApproximation.internal.serializabledata.(savedObject.classname)();
            propNames=string(fieldnames(savedObject.structValue));
            for ii=1:numel(propNames)
                this.(propNames{ii})=savedObject.structValue.(propNames{ii});
            end
        end
    end
end



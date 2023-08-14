classdef BusInput<Simulink.iospecification.InputVariable&Simulink.iospecification.BusLeafAccessInterface





    methods(Static)
        function bool=isa(varIn)
            bool=isBusSignal(varIn);
        end

    end


    properties(Hidden)
        SupportedVarType='bus'
    end


    methods

        function outDataType=getDataType(obj)

            outDataType='struct';
        end


        function outDims=getDimensions(obj)
            outDims=size(obj.Value);
        end


        function outSignalType=getSignalType(obj)
            outSignalType=obj.getComplexString(false);
        end


        function leafValue=getBusLeaf(obj,leafName,varargin)

            rootBusIndex=1;
            if~isempty(varargin)
                rootBusIndex=varargin{1};
            end
            leafValue=obj.Value(rootBusIndex).(leafName);
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.BusInput.isa(varIn);
        end

    end
end

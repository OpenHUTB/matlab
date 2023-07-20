classdef LoggedSignalInput<Simulink.iospecification.InputVariable&Simulink.iospecification.BusLeafAccessInterface





    methods(Static)
        function bool=isa(varIn)
            bool=isa(varIn,'Simulink.SimulationData.Signal')||isa(varIn,'Simulink.SimulationData.Parameter');
        end

    end


    properties(Hidden)
        SupportedVarType='logged signal'


ValueInputVariable
    end


    methods


        function obj=LoggedSignalInput(name,value)

            obj=obj@Simulink.iospecification.InputVariable(name,value);

            inputVarFactory=Simulink.iospecification.InputVariableFactory.getInstance;

            obj.ValueInputVariable=inputVarFactory.getInputVariableType(obj.Name,obj.Value.Values);
        end


        function outDataType=getDataType(obj)

            outDataType=getDataType(obj.ValueInputVariable);
        end


        function outDims=getDimensions(obj)
            outDims=getDimensions(obj.ValueInputVariable);
        end


        function outSignalType=getSignalType(obj)
            outSignalType=getSignalType(obj.ValueInputVariable);
        end


        function leafValue=getBusLeaf(obj,leafName,varargin)

            rootBusIndex=1;
            if~isempty(varargin)
                rootBusIndex=varargin{1};
            end
            leafValue=obj.Value.Values(rootBusIndex).(leafName);
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.LoggedSignalInput.isa(varIn);
        end

    end
end

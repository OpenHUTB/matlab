classdef FunctionCallInput<Simulink.iospecification.InputVariable





    methods(Static)
        function bool=isa(varIn)
            bool=isFunctionCallSignal(varIn);
        end

    end


    properties(Hidden)
        SupportedVarType='function call'
    end


    methods

        function outDataType=getDataType(obj)

            outDataType='double';
        end


        function outDims=getDimensions(obj)
            outDims=obj.getDimension(size(obj.Value));
        end


        function outSignalType=getSignalType(obj)
            outSignalType=obj.getComplexString(false);
        end


        function dim=getDimension(~,dataSize)


            dim=1;
        end


        function diagnosticStruct=areCompatible(obj,inputVariableObj)
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.FunctionCallInput.isa(varIn);
        end

    end
end

classdef SingleInputDataArray<Simulink.iospecification.InputVariable





    methods(Static)
        function bool=isa(varIn)
            bool=isDataArray(varIn);
        end

    end


    properties(Hidden)
        SupportedVarType='dataarray'
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


            dim=dataSize(2)-1;
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.SingleInputDataArray.isa(varIn);
        end

    end
end

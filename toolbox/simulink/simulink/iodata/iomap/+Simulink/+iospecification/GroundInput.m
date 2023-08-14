classdef GroundInput<Simulink.iospecification.InputVariable





    methods(Static)
        function bool=isa(varIn)
            bool=isGroundSignal(varIn);
        end

    end


    properties(Hidden)
        SupportedVarType='ground'
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


            dim=[];
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.GroundInput.isa(varIn);
        end

    end
end

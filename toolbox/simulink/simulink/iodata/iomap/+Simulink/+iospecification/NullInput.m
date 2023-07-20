classdef NullInput<Simulink.iospecification.InputVariable





    methods(Static)
        function bool=isa(varIn)
            bool=false;
        end

    end


    properties(Hidden)
        SupportedVarType='null'
    end


    methods



        function outDataType=getDataType(obj)

            outDataType='double';
        end


        function outDims=getDimensions(obj)
            outDims=[];
        end


        function outSignalType=getSignalType(obj)
            outSignalType='real';
        end


        function dim=getDimension(~,dataSize)


            dim=[];
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=true;
        end

    end
end

classdef TSArrayInput<Simulink.iospecification.InputVariable&Simulink.iospecification.BusLeafAccessInterface





    methods(Static)
        function bool=isa(varIn)
            bool=Simulink.sdi.internal.Util.isTSArray(varIn);
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


        function leafValue=getBusLeaf(obj,leafName,~)


            leafValue=obj.Value.(leafName);
        end
    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.TSArrayInput.isa(varIn);
        end

    end
end

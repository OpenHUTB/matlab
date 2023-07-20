classdef TimeseriesInput<Simulink.iospecification.InputVariable





    methods(Static)
        function bool=isa(varIn)
            bool=isa(varIn,'timeseries')||isa(varIn,'Simulink.Timeseries');
        end

    end


    properties(Hidden)
        SupportedVarType='timeseries'
    end


    methods

        function outDataType=getDataType(obj)
            outDataType=class(obj.Value.Data);
            if strcmp(outDataType,'embedded.fi')
                numType=obj.Value.Data.numerictype;
                outDataType=obj.checkDataForFixedPoint(outDataType,numType);
            end
        end


        function outDims=getDimensions(obj)
            outDims=obj.getDimension(size(obj.Value.Data));
        end


        function outSignalType=getSignalType(obj)
            outSignalType=obj.getComplexString(~isreal(obj.Value.Data)&&~isstring(obj.Value.Data));
        end

    end


    methods(Access='protected')


        function bool=isValidInputForm(~,varIn)
            bool=Simulink.iospecification.TimeseriesInput.isa(varIn);
        end

    end
end

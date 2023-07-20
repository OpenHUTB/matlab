classdef NullConverter<FunctionApproximation.internal.losslessdatatypeconverter.LosslessDataTypeConverter





    methods
        function[addUnit,newDBUnit]=convert(~,dbUnit,~)
            addUnit=false;
            newDBUnit=dbUnit;
        end
    end
end

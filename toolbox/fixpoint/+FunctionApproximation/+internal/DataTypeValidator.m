classdef DataTypeValidator<handle




    methods(Static)
        function validateSupportedDataTypes(inputType,outputType)
            for i=1:numel(inputType)
                isValidInputType=FunctionApproximation.internal.DataTypeValidator.validateDataType(inputType(i));
            end
            isValidOutputType=FunctionApproximation.internal.DataTypeValidator.validateDataType(outputType);

            isValid=isValidInputType&&isValidOutputType;

            if~isValid


                ME=MException(message('SimulinkFixedPoint:functionApproximation:unsupportedDataType'));
                throw(ME);
            end
        end

        function isValid=validateDataType(dataType)
            isValid=isscalingbinarypoint(dataType)||isscalingslopebias(dataType)||isfloat(dataType);
        end
    end
end

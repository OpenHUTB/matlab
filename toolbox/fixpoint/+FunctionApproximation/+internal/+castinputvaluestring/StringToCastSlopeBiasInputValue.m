classdef StringToCastSlopeBiasInputValue<FunctionApproximation.internal.castinputvaluestring.StringToCastInput





    methods(Static)
        function castInputString=getStringToCastInputValue(inputType,breakpointValuesType,inputNumber)
            inputType=fi([],inputType);
            inputType.SumMode='SpecifyPrecision';
            inputType.SumWordLength=inputType.WordLength+1;
            inputType.SumFractionLength=max(breakpointValuesType.FractionLength,inputType.FractionLength);




            inputType.ProductMode='SpecifyPrecision';
            inputType.ProductWordLength=inputType.SumWordLength+inputType.SumWordLength;
            inputType.ProductFractionLength=inputType.SumWordLength-1;

            castInputString=[newline,'inputValues',num2str(inputNumber),' = cast(inputValues',num2str(inputNumber),',''like'',',...
            inputType.tostring,');',newline];
        end
    end
end

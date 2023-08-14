classdef BreakpointValuesStringForFixedSlopeBias<handle



    methods(Static)
        function breakpointValuesString=getBreakpointValuesString(breakpointValues,breakpointValuesType,inputType,inputNumber)
            if iscell(breakpointValues)
                breakpointValues=breakpointValues{inputNumber};
            end

            breakpointValues=fi(breakpointValues,breakpointValuesType);
            breakpointValues.SumMode='SpecifyPrecision';
            breakpointValues.SumWordLength=inputType.WordLength+1;
            breakpointValues.SumFractionLength=max(breakpointValuesType.FractionLength,inputType.FractionLength);
            breakpointValues.ProductMode='SpecifyPrecision';




            breakpointValues.ProductWordLength=breakpointValues.SumWordLength+breakpointValues.SumWordLength;
            breakpointValues.ProductFractionLength=breakpointValues.SumWordLength-1;

            breakpointValuesString=[newline,'breakpointValues',num2str(inputNumber),' = coder.const(',breakpointValues.tostring,');',newline];
        end
    end
end

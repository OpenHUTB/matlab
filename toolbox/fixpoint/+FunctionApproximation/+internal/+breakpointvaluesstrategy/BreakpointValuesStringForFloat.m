classdef BreakpointValuesStringForFloat<handle



    methods(Static)
        function breakpointValuesString=getBreakpointValuesString(breakpointValues,breakpointValuesType,inputNumber)
            if iscell(breakpointValues)
                breakpointValues=breakpointValues{inputNumber};
            end

            breakpointValuesString=['breakpointValues',num2str(inputNumber),' = coder.const(',mat2str(fixed.internal.math.castUniversal(breakpointValues,breakpointValuesType.tostring,0),'class'),...
            ');',newline];
        end
    end
end

classdef BreakpointValuesStringForFixed<handle



    methods(Static)
        function breakpointValuesString=getBreakpointValuesString(breakpointValues,breakpointValuesType,inputNumber)
            if iscell(breakpointValues)
                breakpointValues=breakpointValues{inputNumber};
            end

            breakpointValuesString=['breakpointValues',num2str(inputNumber),' = coder.const(fi(',mat2str(breakpointValues),',',...
            breakpointValuesType.tostring,'));',newline];
        end
    end
end

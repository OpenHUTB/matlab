classdef BreakpointValuesFromVariableFixedSlopeBias<handle




    methods(Static)
        function breakpointValuesString=getBreakpointValuesString(inputNumber)
            breakpointValuesString=['breakpointValues',num2str(inputNumber),' = data.breakpointValues{',num2str(inputNumber),'};'];
        end
    end
end
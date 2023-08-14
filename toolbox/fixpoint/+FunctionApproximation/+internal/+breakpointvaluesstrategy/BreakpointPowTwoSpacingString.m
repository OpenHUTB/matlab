classdef BreakpointPowTwoSpacingString<handle



    methods(Static)
        function bpSpaceString=getBreakpointSpacingString(breakpointValues,inputNumber)
            if iscell(breakpointValues)
                breakpointValues=breakpointValues{inputNumber};
            end

            bpSpaceExponent=round(log2(breakpointValues(2)-breakpointValues(1)));
            bpSpaceString=['bpSpaceExponent',num2str(inputNumber),' = ',mat2str(-bpSpaceExponent),';',newline];
        end
    end
end

classdef BreakpointSpacingString<handle



    methods(Static)
        function bpSpaceString=getBreakpointSpacingString(breakpointValues,inputNumber)
            bpSpaceString='';

            if iscell(breakpointValues)
                breakpointValues=breakpointValues{inputNumber};
            end

            bpSpacing=diff(breakpointValues);
            if~isempty(bpSpacing)
                bpSpaceString=['bpSpace',num2str(inputNumber),' = ',mat2str(bpSpacing(1)),';',newline];
            end
        end
    end
end

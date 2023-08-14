classdef BaseEvalWorkspace

    methods(Static)
        function whoResult=who()
            whoResult=evalin('base','who');
        end

        function value=getValue(variableName)
            value=evalin('base',variableName);
        end

        function assignin(variableName,variableValue)
            assignin('base',variableName,variableValue);
        end

        function clear()
            evalin('base','clear');
        end
    end
end

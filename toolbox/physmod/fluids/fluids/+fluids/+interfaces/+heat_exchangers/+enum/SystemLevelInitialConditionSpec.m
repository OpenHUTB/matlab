classdef SystemLevelInitialConditionSpec<int32





    enumeration
        Operating(1)
        Specify(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Operating')='Same as nominal operating condition';
            map('Specify')='Specify initial condition';
        end
    end
end
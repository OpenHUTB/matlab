classdef EfficiencyType<int32





    enumeration
        Constant(1)
        Analytical(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Constant')='Constant';
            map('Analytical')='Analytical';
        end
    end
end
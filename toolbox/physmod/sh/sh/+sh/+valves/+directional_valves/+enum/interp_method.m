classdef interp_method<int32





    enumeration
        linear(1)
        smooth(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('linear')='Linear';
            map('smooth')='Smooth';
        end
    end
end
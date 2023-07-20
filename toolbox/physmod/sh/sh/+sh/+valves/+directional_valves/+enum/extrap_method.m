classdef extrap_method<int32





    enumeration
        linear(1)
        nearest(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('linear')='Linear';
            map('nearest')='Nearest';
        end
    end
end
classdef valve_opening_spec<int32





    enumeration
        linear(1)
        quick(2)
        equal(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('linear')='Linear';
            map('quick')='Quick opening';
            map('equal')='Equal percentage';
        end
    end
end

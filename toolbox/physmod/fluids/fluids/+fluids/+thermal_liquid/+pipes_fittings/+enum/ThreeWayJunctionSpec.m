classdef ThreeWayJunctionSpec<int32




    enumeration
        Standard(1)
        Custom(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Standard')='Standard';
            map('Custom')='Custom';
        end
    end
end

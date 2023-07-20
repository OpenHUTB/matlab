classdef wall_spec<int32




    enumeration
        rigid(1)
        flexible(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('rigid')='Rigid';
            map('flexible')='Flexible';
        end
    end
end
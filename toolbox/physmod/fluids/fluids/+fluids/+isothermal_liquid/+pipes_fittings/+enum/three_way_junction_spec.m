classdef three_way_junction_spec<int32





    enumeration
        standard(1)
        custom(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('standard')='Standard';
            map('custom')='Custom';
        end
    end
end
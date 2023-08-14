classdef BraidStretching<int32





    enumeration
        Inelastic(0)
        Elastic(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Inelastic')='Inelastic braids';
            map('Elastic')='Elastic braids';
        end
    end
end
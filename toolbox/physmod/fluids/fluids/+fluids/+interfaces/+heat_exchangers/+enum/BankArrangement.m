classdef BankArrangement<int32





    enumeration
        Inline(1)
        Staggered(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Inline')='Inline';
            map('Staggered')='Staggered';
        end
    end
end
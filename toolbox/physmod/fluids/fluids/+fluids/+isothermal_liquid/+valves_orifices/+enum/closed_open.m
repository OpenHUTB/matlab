classdef closed_open<int32





    enumeration
        open(1)
        closed(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('open')='Normally open';
            map('closed')='Normally closed';
        end
    end
end
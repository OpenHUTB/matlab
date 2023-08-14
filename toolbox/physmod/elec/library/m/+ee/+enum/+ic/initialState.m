classdef initialState<int32





    enumeration
        low(1)
        high(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('low')='physmod:ee:library:comments:enum:ic:initialState:map_Low';
            map('high')='physmod:ee:library:comments:enum:ic:initialState:map_High';
        end
    end
end
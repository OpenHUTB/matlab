classdef internalvariables<int32



    enumeration
        uninstrumented(1)
        instrumented(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('uninstrumented')='physmod:ee:library:comments:enum:internalvariables:map_Uninstrumented';
            map('instrumented')='physmod:ee:library:comments:enum:internalvariables:map_Instrumented';
        end
    end
end

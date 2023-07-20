classdef event<int32




    enumeration
        asynchronous(1)
        discrete(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('asynchronous')='physmod:ee:library:comments:enum:ic:event:map_AsynchronousBestForVariableStepSolvers';
            map('discrete')='physmod:ee:library:comments:enum:ic:event:map_DiscreteTimeBestForFixedStepSolvers';
        end
    end
end
classdef WLCombinationGeneratorFactory<handle





    methods(Static)
        function generator=getGenerator(options)%#ok<INUSD>
            generator=FunctionApproximation.internal.solvers.GenericWLCombinationGenerator();
        end
    end
end

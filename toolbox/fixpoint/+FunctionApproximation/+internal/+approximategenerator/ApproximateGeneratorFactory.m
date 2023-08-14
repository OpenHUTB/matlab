classdef ApproximateGeneratorFactory




    methods(Static)
        function generator=getApproximateGenerator(options)
            if options.ApproximateSolutionType==FunctionApproximation.internal.ApproximateSolutionType.Simulink
                generator=FunctionApproximation.internal.approximategenerator.SimulinkLUTApproximateGenerator();
            else
                generator=FunctionApproximation.internal.approximategenerator.MATLABLUTApproximateGenerator();
            end
        end
    end
end

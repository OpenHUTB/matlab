classdef WLConstraintGeneratorFactory<handle




    methods(Static)
        function generator=getConstraintGenerator(options)



            if(options.Interpolation=="Nearest")||options.AUTOSARCompliant
                generator=FunctionApproximation.internal.solvers.AllWLConstraintGenerator();
            else
                generator=FunctionApproximation.internal.solvers.NullWLConstraintGenerator();
            end
        end
    end
end
classdef NullWLConstraintGenerator<FunctionApproximation.internal.solvers.WLConstraintGenerator




    methods
        function constraints=getConstraints(~,problemObject,~)
            constraints=cell(1,problemObject.NumberOfInputs+1);
        end
    end
end



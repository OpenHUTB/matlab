classdef AllWLConstraintGenerator<FunctionApproximation.internal.solvers.NullWLConstraintGenerator





    methods
        function constriants=getConstraints(this,problemObject,options)

            constriants=getConstraints@FunctionApproximation.internal.solvers.NullWLConstraintGenerator(this,problemObject,options);


            indicesWithConstraints=FunctionApproximation.internal.solvers.getIndicesForWLConstraints(problemObject.NumberOfInputs,options);


            interfaceTypes=[problemObject.InputTypes,problemObject.OutputType];
            for index=indicesWithConstraints
                constriants{index}=interfaceTypes(index).WordLength;
            end
        end
    end
end
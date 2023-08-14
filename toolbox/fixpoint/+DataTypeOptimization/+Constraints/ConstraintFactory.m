classdef ConstraintFactory<handle








    methods(Access=public,Static)
        function constraint=getConstraint(blockPath,portIndex,toleranceType,toleranceValue)






            switch(toleranceType)
            case 'AbsTol'
                constraint=DataTypeOptimization.Constraints.AbsoluteTolerance(blockPath,portIndex,toleranceValue);
            case 'RelTol'
                constraint=DataTypeOptimization.Constraints.RelativeTolerance(blockPath,portIndex,toleranceValue);
            case 'TimeTol'
                constraint=DataTypeOptimization.Constraints.TimeTolerance(blockPath,portIndex,toleranceValue);
            case 'Assertion'
                constraint=DataTypeOptimization.Constraints.AssertionConstraint(blockPath);
            otherwise
                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:incorrectToleranceType');
            end
        end
    end
end



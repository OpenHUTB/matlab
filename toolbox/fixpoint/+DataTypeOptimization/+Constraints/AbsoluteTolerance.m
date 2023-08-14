classdef AbsoluteTolerance<DataTypeOptimization.Constraints.ToleranceConstraint





    methods(Access=public)
        function this=AbsoluteTolerance(path,portIndex,value)
            this@DataTypeOptimization.Constraints.ToleranceConstraint(path,portIndex,value);
        end

        function modeStr=getMode(~)
            modeStr='AbsTol';
        end

    end

end
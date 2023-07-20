classdef TimeTolerance<DataTypeOptimization.Constraints.ToleranceConstraint





    methods(Access=public)
        function this=TimeTolerance(path,portIndex,value)
            this@DataTypeOptimization.Constraints.ToleranceConstraint(path,portIndex,value);
        end

        function modeStr=getMode(~)
            modeStr='TimeTol';
        end

    end

end
classdef RelativeTolerance<DataTypeOptimization.Constraints.ToleranceConstraint






    methods(Access=public)
        function this=RelativeTolerance(path,portIndex,value)
            this@DataTypeOptimization.Constraints.ToleranceConstraint(path,portIndex,value);
        end

        function modeStr=getMode(~)
            modeStr='RelTol';
        end
    end

end
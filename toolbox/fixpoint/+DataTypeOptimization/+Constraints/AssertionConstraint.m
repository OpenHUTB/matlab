classdef AssertionConstraint<DataTypeOptimization.Constraints.AbstractConstraint




    properties(SetAccess=private,Hidden)
iPath
    end

    methods(Access=public)
        function this=AssertionConstraint(path)
            this@DataTypeOptimization.Constraints.AbstractConstraint(path,-1,nan);
        end

        function initializeConstraint(this,path,~,~)
            bp=Simulink.BlockPath(path);
            this.iPath=bp.convertToCell{1};
            this.value=nan;
        end

        function modeStr=getMode(~)
            modeStr='Assertion';
        end

    end

    methods(Hidden)
        function p=getPath(this)
            p=this.iPath;
        end

        function p=getPortIndex(~)
            p=-1;
        end
    end

end
classdef Options<matlab.mixin.CustomDisplay&FunctionApproximation.internal.option.OptionsData
























































    properties(Hidden,SetAccess=private)
        OptimStateController FunctionApproximation.internal.solvers.OptimizationStateController
    end

    properties(Hidden)
        DataBaseObservers(1,:)FunctionApproximation.internal.database.DataBaseObserver
        LicenseCheck(1,1)logical
    end

    properties(Hidden,SetAccess=private)
        LicenseChecked=false;
    end

    methods
        function this=Options(varargin)
            this=this@FunctionApproximation.internal.option.OptionsData(varargin{:});
            p=inputParser();
            p.KeepUnmatched=true;
            addParameter(p,'LicenseCheck',true);
            addParameter(p,'DataBaseObservers',FunctionApproximation.internal.database.PrintDataBaseUnitObserver());
            parse(p,varargin{:});
            this.LicenseCheck=p.Results.LicenseCheck;
            this.DataBaseObservers=p.Results.DataBaseObservers;
            if this.LicenseCheck
                FunctionApproximation.internal.Utils.licenseCheck();
                this.LicenseChecked=true;
            end
            this.OptimStateController=FunctionApproximation.internal.solvers.OptimizationStateController();
        end
    end

    methods(Hidden)
        function flag=isequal(this,other)
            flag=isequal(class(this),class(other));
            allProperties=properties(this);
            for ii=1:numel(allProperties)
                currentProperty=allProperties{ii};
                flag=flag&&isequal(this.(currentProperty),other.(currentProperty));
            end
        end

        function flag=isequaln(this,other)
            flag=FunctionApproximation.internal.isequaln(this,other);
        end

        function struct(this)
            error(message('SimulinkFixedPoint:functionApproximation:cannotConvertToStruct',class(this)));
        end

        function controller=getOptimizationStateController(this)
            controller=this.OptimStateController;
        end
    end

    methods(Access=private)
        function validateAgainstUnit(this,value)
            if this.MemoryUnits=="bits"
                try
                    mustBeInteger(value);
                catch err
                    err.throwAsCaller()
                end
            end
        end
    end

    methods(Access=protected)
        function header=getHeader(this)
            dimStr=matlab.mixin.CustomDisplay.convertDimensionsToString(this);
            header=FunctionApproximation.internal.DisplayUtils.getClassHeaderString(...
            this,...
            message('SimulinkFixedPoint:functionApproximation:withProperties').getString(),...
            dimStr);
        end
    end
end

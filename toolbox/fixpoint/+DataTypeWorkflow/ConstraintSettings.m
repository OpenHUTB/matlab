classdef ConstraintSettings<handle





    properties(Access={?DataTypeWorkflowTestCase})
        OptimizationOptions;
    end

    methods
        function obj=ConstraintSettings()
            obj.OptimizationOptions=fxpOptimizationOptions();
        end

        function addTolerance(this,blockPath,portIndex,tolType,tolValue)
            addTolerance(this.OptimizationOptions,blockPath,portIndex,tolType,tolValue);
        end

        function showTolerances(this)
            showTolerances(this.OptimizationOptions);
        end

        function clearTolerances(this)
            this.OptimizationOptions.clearTolerances();
        end

    end

    methods(Hidden)
        function opt=getOptimizationOptions(this)
            opt=this.OptimizationOptions;
        end

        function opt=injectOptimizationOptions(this,opt)
            this.OptimizationOptions=opt;
        end
    end
end


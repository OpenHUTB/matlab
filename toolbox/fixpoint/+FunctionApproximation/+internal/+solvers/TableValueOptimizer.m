classdef TableValueOptimizer<handle&matlab.mixin.Heterogeneous







    properties(SetAccess=protected,GetAccess=public)
        Context FunctionApproximation.internal.solvers.TableValueOptimizerContext
OptimizedTableValues
    end

    methods(Abstract)
        optimized=optimize(this);
        proceed=proceedToOptimize(this,context,maxError);
    end


    methods(Access=protected)
        function updateContext(this)%#ok<MANU>

        end
    end

    methods(Sealed)
        function setContext(this,context)
            this.Context=context;
            if~isempty(this.Context.TableData)
                this.OptimizedTableValues=this.Context.TableData{end};
            end
            updateContext(this);
        end
    end
end

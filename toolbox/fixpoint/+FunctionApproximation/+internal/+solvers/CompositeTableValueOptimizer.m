classdef(Sealed)CompositeTableValueOptimizer<FunctionApproximation.internal.solvers.TableValueOptimizer





    properties(SetAccess=private)
        Optimizers(1,:)FunctionApproximation.internal.solvers.TableValueOptimizer
        AllOptimizerTableValues cell
    end

    methods(Access=protected)
        function updateContext(this)
            nOptimizer=numel(this.Optimizers);
            for ii=1:nOptimizer
                this.Optimizers(ii).setContext(this.Context);
            end
        end
    end

    methods
        function this=CompositeTableValueOptimizer(optimizers)
            this.Optimizers=optimizers;
            this.AllOptimizerTableValues=cell(1,numel(optimizers));
        end

        function optimized=optimize(this)
            nOptimizer=numel(this.Optimizers);
            optimizedVector=false(1,nOptimizer);
            for ii=1:nOptimizer
                optimizedVector(ii)=this.Optimizers(ii).optimize();
                tableValues=this.Optimizers(ii).OptimizedTableValues;
                this.AllOptimizerTableValues{ii}=tableValues;
                if ii<nOptimizer


                    this.Optimizers(ii+1).Context.TableData{end}=tableValues;
                end
            end
            this.OptimizedTableValues=tableValues;
            optimized=any(optimizedVector(ii));
        end


        function proceed=proceedToOptimize(this,context,maxError)
            nOptimizer=numel(this.Optimizers);
            proceed=true;
            for ii=1:nOptimizer
                proceed=this.Optimizers(ii).proceedToOptimize(context,maxError);
                if~proceed


                    break;
                end
            end
        end
    end
end

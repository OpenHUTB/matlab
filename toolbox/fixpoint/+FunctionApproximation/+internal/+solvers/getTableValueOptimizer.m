function tableValueOptimizer=getTableValueOptimizer(tableValueOptimizerContext)





    tableValueOptimizer=FunctionApproximation.internal.solvers.TableValueOptimizer.empty();
    options=tableValueOptimizerContext.Options;
    if~options.OnCurveTableValues
        if options.Interpolation=="Flat"||options.Interpolation=="Nearest"
            tableValueOptimizer=FunctionApproximation.internal.solvers.ZOESTableValueOptimizer();
        else
            tableValueOptimizer=FunctionApproximation.internal.solvers.PNormSQPTableValueOptimizer();
        end
    end
end

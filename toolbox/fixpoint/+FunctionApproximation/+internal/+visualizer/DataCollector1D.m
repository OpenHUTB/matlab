classdef DataCollector1D<FunctionApproximation.internal.visualizer.DataCollector





    methods
        function dataContext=collect(this,solutionObject)

            f1=getFunctionWrapperForAbsError(this,solutionObject);
            f2=getFunctionWrapperForMaxDiff(this,solutionObject);
            rangeObject=getRangeObject(this,solutionObject);
            gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(solutionObject.SourceProblem.InputTypes);
            gridCell=getGrid(gridCreator,rangeObject,2^min(16,solutionObject.SourceProblem.InputTypes.WordLength));
            x=gridCell{1}';


            dataContext=collect@FunctionApproximation.internal.visualizer.DataCollector(this,solutionObject);
            dataContext.Breakpoints={x};
            dataContext.Original=solutionObject.ErrorFunction.Original.evaluate(x);
            dataContext.Approximate=solutionObject.ErrorFunction.Approximation.evaluate(x);
            dataContext.AbsDiff=f1.evaluate(x);
            dataContext.MaxDiff=f2.evaluate(x);
        end
    end
end
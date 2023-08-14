classdef DataCollector2D<FunctionApproximation.internal.visualizer.DataCollector




    methods
        function dataContext=collect(this,solutionObject)

            f1=getFunctionWrapperForAbsError(this,solutionObject);
            f2=getFunctionWrapperForMaxDiff(this,solutionObject);
            rangeObject=getRangeObject(this,solutionObject);
            gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(solutionObject.SourceProblem.InputTypes);
            gridCell=getGrid(gridCreator,rangeObject,[2^8,2^8]);
            gridObject=FunctionApproximation.internal.Grid(gridCell,gridCreator);
            x=gridObject.getSets();
            y1=solutionObject.ErrorFunction.Original.evaluate(x);
            y2=solutionObject.ErrorFunction.Approximation.evaluate(x);
            y1Diff=f1.evaluate(x);
            y2Diff=f2.evaluate(x);


            dataContext=collect@FunctionApproximation.internal.visualizer.DataCollector(this,solutionObject);
            dataContext.Breakpoints={reshape(x(:,1),gridObject.GridSize),reshape(x(:,2),gridObject.GridSize)};
            dataContext.Original=reshape(y1,gridObject.GridSize);
            dataContext.Approximate=reshape(y2,gridObject.GridSize);
            dataContext.AbsDiff=reshape(y1Diff,gridObject.GridSize);
            dataContext.MaxDiff=reshape(y2Diff,gridObject.GridSize);
        end
    end
end
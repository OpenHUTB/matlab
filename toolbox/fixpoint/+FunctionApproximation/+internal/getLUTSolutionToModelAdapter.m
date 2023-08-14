function adapter=getLUTSolutionToModelAdapter(useApproximationBlock)




    if useApproximationBlock
        adapter=FunctionApproximation.internal.LUTSolutionToApproximationBlockModelAdapter();
    else
        adapter=FunctionApproximation.internal.LUTSolutionToModelAdapter();
    end
end
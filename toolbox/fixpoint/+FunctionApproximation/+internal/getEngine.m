function engine=getEngine(problemObject)




    if problemObject.Options.Interpolation=="None"
        engine=FunctionApproximation.internal.ApproximateDirectLUTGeneratorEngine(problemObject);
    else
        if problemObject.Options.UseParallel...
            &&matlab.internal.parallel.canUseParallelPool()


            engine=FunctionApproximation.internal.ParallelLUTGeneratorEngine(problemObject);
        else
            engine=FunctionApproximation.internal.SequentialLUTGeneratorEngine(problemObject);
        end
    end
end

function extremaFinder=getExtremaFinder(extremaStrategy,extremaType)



    if isempty(extremaStrategy)
        extremaFinder=FunctionApproximation.internal.extremafinders.BruteForceMinimaFinder;
    else
        extremaFinder=FunctionApproximation.internal.extremafinders.ExtremaStrategyMinimaFinder(extremaStrategy);
    end

    if extremaType==FunctionApproximation.internal.ExtremaType.Maximize
        extremaFinder=FunctionApproximation.internal.extremafinders.MaximaFinder(extremaFinder);
    end
end

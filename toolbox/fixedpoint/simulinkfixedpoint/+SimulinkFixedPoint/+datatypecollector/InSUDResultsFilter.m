classdef(Sealed)InSUDResultsFilter<SimulinkFixedPoint.datatypecollector.ResultsFilter




    methods
        function filteredResults=filter(this,allResults)
            filteredResults=SimulinkFixedPoint.AutoscalerUtils.getResultsInSUD(allResults,this.SUD);
        end
    end
end

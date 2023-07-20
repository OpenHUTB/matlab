classdef MinFeasibleSolutionsStrategy<FunctionApproximation.internal.progresstracking.TrackingStrategy






    properties
DataBase
MinFeasibleSolutions
MinFractionFeasibleSolutions
    end

    methods
        function this=MinFeasibleSolutionsStrategy(dataBase,minFeasibleSolutions,minFractionFeasibleSolutions)

            this.DataBase=dataBase;

            this.MinFeasibleSolutions=minFeasibleSolutions;

            this.MinFractionFeasibleSolutions=minFractionFeasibleSolutions;
        end

        function initialize(~)

        end

        function diagnostic=check(this)
            diagnostic=MException.empty();

            feasibleEntries=this.DataBase.getFeasibleDBUnits;
            numFeasibleEntries=numel(feasibleEntries);

            minNumReached=(numFeasibleEntries>=this.MinFeasibleSolutions);

            if numFeasibleEntries


                numEntriesAfterFirstFeasible=this.DataBase.Count-feasibleEntries(1).ID+1;
                ratioFeasibleSolutions=Inf;
                if numEntriesAfterFirstFeasible>0



                    ratioFeasibleSolutions=numFeasibleEntries/numEntriesAfterFirstFeasible;
                end
                minRatioReached=ratioFeasibleSolutions<=this.MinFractionFeasibleSolutions;
            else
                minRatioReached=false;
            end



            if minNumReached||minRatioReached
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:minFeasibleSolutionsReached'));
            end
        end

        function diagnostic=advance(this)
            diagnostic=this.check();
        end
    end
end

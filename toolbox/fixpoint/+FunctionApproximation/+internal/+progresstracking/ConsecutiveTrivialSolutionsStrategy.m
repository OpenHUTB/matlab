classdef ConsecutiveTrivialSolutionsStrategy<FunctionApproximation.internal.progresstracking.TrackingStrategy






    properties
DataBase
UpperBoundConsecutiveTrivialSolutions
    end

    methods
        function this=ConsecutiveTrivialSolutionsStrategy(dataBase,upperBoundConsecutiveTrivialSolutions)

            this.DataBase=dataBase;


            this.UpperBoundConsecutiveTrivialSolutions=upperBoundConsecutiveTrivialSolutions;
        end

        function initialize(~)

        end

        function diagnostic=check(this)
            diagnostic=MException.empty();

            counter=0;
            feasibleDBUnits=getFeasibleDBUnits(this.DataBase);
            if~isempty(feasibleDBUnits)
                for unitID=(this.DataBase.Count-1):-1:0
                    dbUnit=getDBUnitFromID(this.DataBase,unitID);




                    isTrivialSolution=all(dbUnit.GridSize<=3);
                    if isTrivialSolution
                        counter=counter+1;
                    else
                        break;
                    end
                end
            end
            maxReached=(counter>=this.UpperBoundConsecutiveTrivialSolutions);



            if maxReached
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:minFeasibleSolutionsReached'));
            end
        end

        function diagnostic=advance(this)
            diagnostic=this.check();
        end
    end

    methods(Static)
        function ub=getUpperBound(numWordLengths)
            ub=max(ceil(numWordLengths/2),8);
        end
    end
end

classdef(Sealed)SequentialLUTGeneratorEngine<FunctionApproximation.internal.ApproximateLUTGeneratorEngine








    methods(Access=protected)
        function executeSolvers(this,allCombinations,solverQueue)
            combinationSetSize=this.getCombinationSetSize(this.Problem.InputFunctionType,this.Options.WordLengths);
            combinationsSet=FunctionApproximation.internal.getCombinationsSet(allCombinations,combinationSetSize);
            dvSetTruncator=FunctionApproximation.internal.DecisionVariableSetTruncator();
            dvSetTruncator.ConstraintTracker=solverQueue(1).HardConsTracker;
            maxObjectiveValue=this.Options.DefaultMemoryUsageBits;
            for iSet=1:numel(combinationsSet)
                combinations=dvSetTruncator.truncate(this.Problem,this.Options,combinationsSet{iSet});
                if~isempty(combinations)
                    for ii=1:numel(solverQueue)
                        errorFeasibleDBUnits=getFeasibleDBUnits(solverQueue(ii).DataBase,1);
                        bestDBUnit=getBest(solverQueue(ii).DataBase,errorFeasibleDBUnits);
                        if~isempty(bestDBUnit)
                            maxObjectiveValue=min(bestDBUnit.ObjectiveValue,this.Options.DefaultMemoryUsageBits);
                        end
                        solverQueue(ii).setMaxObjectiveValue(maxObjectiveValue);
                        solverQueue(ii).solve(combinations);
                    end
                end

                if~solverQueue(1).SoftConsTracker.advance()...
                    ||~solverQueue(1).HardConsTracker.advance()
                    break;
                end
            end
        end

        function registerDataBase(this,solverQueue)
            for ii=1:numel(solverQueue)
                solverQueue(ii).DataBase=this.DataBase;
            end
        end
    end
end
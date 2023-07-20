classdef(Sealed)ApproximateDirectLUTGeneratorEngine<FunctionApproximation.internal.ApproximateGeneratorEngine





    methods
        function this=ApproximateDirectLUTGeneratorEngine(problemObject)
            this=this@FunctionApproximation.internal.ApproximateGeneratorEngine(problemObject);
        end

        function[diagnostic,solution]=run(this)

            factoryObject=FunctionApproximation.internal.ApproximateDirectLUDecisionVariableSetFactory();
            combinations=factoryObject.getApproximateLUTDecisionVariableSet(this.Problem,this.Options);

            value=min(max(floor(numel(combinations)/3),...
            this.Options.MinFeasibleSolutions),10);
            this.Options=FunctionApproximation.internal.ProblemDefinitionFactory.setOptionsProperty(...
            this.Options,'MinFeasibleSolutions',value);

            solverQueue=FunctionApproximation.internal.solvers.DirectLUSolver();
            solverQueue.setMaxObjectiveValue(this.Options.DefaultMemoryUsageBits);
            solverQueue.DataBase=this.DataBase;


            [softConsTracker,hardConsTracker]=FunctionApproximation.internal.progresstracking.getConstraintsProgressTracker(this.DataBase,this.Options);
            softConsTracker.initialize();
            hardConsTracker.initialize();
            solverQueue.SoftConsTracker=softConsTracker;
            solverQueue.HardConsTracker=hardConsTracker;

            this.updateOptionsOnSolvers(solverQueue,this.Options);
            solverQueue.registerDependencies(this.Problem);
            solverQueue.solve(combinations);

            adapter=FunctionApproximation.internal.LUTDBUnitToApproximateLUTSolutionAdapter;
            [solution,diagnostic]=adapter.createSolution(this.DataBase.getBest(),this.Problem,this.Options,this.DataBase);
        end
    end
end

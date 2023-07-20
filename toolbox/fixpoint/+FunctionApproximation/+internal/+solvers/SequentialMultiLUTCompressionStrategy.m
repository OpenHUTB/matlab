classdef SequentialMultiLUTCompressionStrategy<FunctionApproximation.internal.solvers.MultiLUTCompressionStrategy




    methods
        function execute(this,blockPaths,options)
            nSolutions=numel(blockPaths);
            this.Solutions=cell(1,nSolutions);
            for iSolution=1:nSolutions
                localOptions=this.updateOptions(blockPaths{iSolution},options);
                localOptions.Display=false;
                blockPath=blockPaths{iSolution};
                try
                    problemObject=FunctionApproximation.Problem(blockPath,'Options',localOptions);
                    solution=solve(problemObject);
                    addSolution(this,solution,iSolution,options);
                catch
                    addSolution(this,FunctionApproximation.LUTSolution.empty(),iSolution,options);
                end
            end
        end
    end
end
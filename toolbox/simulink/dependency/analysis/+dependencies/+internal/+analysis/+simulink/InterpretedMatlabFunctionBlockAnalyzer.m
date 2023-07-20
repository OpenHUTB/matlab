classdef InterpretedMatlabFunctionBlockAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        InterpretedMATLABFcnType='InterpretedMATLABFcn';
    end

    methods

        function this=InterpretedMatlabFunctionBlockAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.MatlabCode=createParameterQuery('MATLABFcn','BlockType','MATLABFcn');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            code=matches.MatlabCode.Value;
            blocks=matches.MatlabCode.BlockPath;

            for n=1:length(blocks)
                maskWorkspace=handler.getMaskedWorkspace(blocks{n});
                if maskWorkspace.Scope==dependencies.internal.analysis.matlab.Scope.Mask

                    workspace=dependencies.internal.analysis.matlab.Workspace;
                    workspace.addVariables(maskWorkspace.Variables);
                else

                    workspace=dependencies.internal.analysis.matlab.Workspace.createChildWorkspace(handler.BaseWorkspace,"");
                end


                workspace.addVariables("u");


                blockComp=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,blockComp,this.InterpretedMATLABFcnType);
                deps=[deps,handler.Analyzers.MATLAB.analyze(code{n},factory,workspace)];%#ok<AGROW>
            end
        end

    end

end

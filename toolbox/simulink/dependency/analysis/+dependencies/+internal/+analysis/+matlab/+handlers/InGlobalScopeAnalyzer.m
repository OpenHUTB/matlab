classdef InGlobalScopeAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions=[
"evalinGlobalScope"
"assigninGlobalScope"
"existsInGlobalScope"
        ];

        MinimumArguments=2;
        StringArguments=2;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,matlabAnalyzer,ref,dependencyFactory)
            import dependencies.internal.analysis.matlab.Workspace
            import dependencies.internal.analysis.findFile;
            import dependencies.internal.analysis.matlab.Reference;

            refs=dependencies.internal.analysis.matlab.Reference.empty;
            arg=ref.InputArguments;
            fct=ref.Function.Value;
            workspace=Workspace.createChildWorkspace(matlabAnalyzer.BaseWorkspace,fct);
            if arg(1).IsString
                node=matlabAnalyzer.findFile(dependencyFactory.Node,arg(1).Value,[".slx",".mdl"]);
                refs=Reference(workspace,node,arg(1).Line,arg(1).Position,'FunctionArgument');
            end
            if strcmp(fct,'evalinGlobalScope')
                tmprefs=matlabAnalyzer.analyzeFragment(arg(2).Value,workspace,dependencyFactory,arg(2).Line);
                isNameResolved=arrayfun(@(x)matlabAnalyzer.resolve(dependencyFactory.Node,x.Function.Value).Resolved,tmprefs);
                refs=[refs,tmprefs(isNameResolved)];
            end

        end

    end

end

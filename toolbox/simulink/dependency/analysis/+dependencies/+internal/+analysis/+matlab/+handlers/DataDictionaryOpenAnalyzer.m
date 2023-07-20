classdef DataDictionaryOpenAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions=["Simulink.data.dictionary.open","Simulink.data.dictionary.create"];
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,matlabAnalyzer,ref,dependencyFactory)
            import dependencies.internal.analysis.matlab.Reference;
            import dependencies.internal.analysis.findFile;

            arg=ref.InputArguments(1);
            node=matlabAnalyzer.findFile(dependencyFactory.Node,arg.Value,".sldd");
            refs=Reference(ref.Workspace,node,arg.Line,arg.Position,"FunctionArgument");
        end

    end

end

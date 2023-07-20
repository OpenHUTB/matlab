classdef ImportDataAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="importdata";
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,matlabAnalyzer,ref,dependencyFactory)
            import dependencies.internal.analysis.matlab.Reference;

            arg=ref.InputArguments(1);
            file=arg.Value;


            if strcmp(file,'-pastespecial')
                refs=dependencies.internal.analysis.matlab.Reference.empty;
            else
                node=matlabAnalyzer.findFile(dependencyFactory.Node,file,{});
                refs=Reference(ref.Workspace,node,arg.Line,arg.Position,'FunctionArgument');
            end
        end

    end

end

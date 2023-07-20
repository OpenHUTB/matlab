classdef MaskedImageFunctionAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions={'image'};
        MinimumArguments=1;
        StringArguments=[];
        AllowedArguments={};
    end

    methods

        function refs=analyze(~,matlabAnalyzer,ref,dependencyFactory)
            import dependencies.internal.analysis.matlab.Reference;
            import dependencies.internal.analysis.findFile;

            arg=ref.InputArguments(1);
            if arg.IsString&&~strcmp(arg.Value,'$imagefile')
                node=matlabAnalyzer.findFile(dependencyFactory.Node,arg.Value,{});
                refs=Reference(ref.Workspace,node,arg.Line,arg.Position,'FunctionArgument');
            else
                refs=Reference.empty;
            end
        end

    end

end

classdef AddBlockAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="add_block";
        MinimumArguments=2;
        StringArguments=[1,2];
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,~,ref,~)
            refs=[];
            for i=1:2
                refs=[refs,i_createRefFor(ref.InputArguments(i),ref.Workspace)];%#ok<AGROW>
            end
        end

    end

end

function ref=i_createRefFor(arg,workspace)
    import dependencies.internal.analysis.matlab.Reference;
    import dependencies.internal.analysis.findSymbol;
    path=strtok(arg.Value,"/");
    if strcmp(path,"built-in")


        ref=[];
    else
        node=findSymbol(path);
        ref=Reference(workspace,node,arg.Line,arg.Position,"FunctionArgument");
    end
end

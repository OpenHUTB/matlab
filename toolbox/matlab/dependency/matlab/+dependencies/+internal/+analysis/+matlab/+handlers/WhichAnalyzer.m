classdef WhichAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="which";
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,~,ref,~)
            import dependencies.internal.analysis.matlab.Reference;

            arg=i_select_input(ref.InputArguments);

            if~isempty(arg)
                symbol=arg.Value;
                try
                    result=which(symbol);
                    node=dependencies.internal.graph.Node.createFileNode(result);
                    if~node.Resolved
                        node=dependencies.internal.graph.Node.createFileNode(symbol);
                    end
                catch
                    node=dependencies.internal.graph.Node.createFileNode(symbol);
                end
                refs=Reference(ref.Workspace,node,arg.Line,arg.Position,'FunctionArgument');
            else
                refs=Reference.empty;
            end
        end
    end
end

function arg=i_select_input(args)

    if length(args)==3&&strcmp(args(2).Value,'in')&&isNotAnOptionArg(args(3).Value)
        arg=args(3);
        return;
    end

    for arg=args
        if isNotAnOptionArg(arg.Value)
            return;
        end
    end

    arg=dependencies.internal.analysis.matlab.Symbol.empty;
end

function flag=isNotAnOptionArg(argValue)
    flag=~ismember(argValue,{'-all','-subfun'});
end

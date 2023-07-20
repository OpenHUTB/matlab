classdef LoadAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions="load";
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=[];
    end

    methods

        function refs=analyze(~,matlabAnalyzer,ref,factory)


            import dependencies.internal.analysis.matlab.Reference;

            arg=i_select_input(ref.InputArguments);
            if isempty(arg)
                refs=Reference.empty;
                return;
            end

            matName=arg.Value;
            [~,~,ext]=fileparts(matName);
            if isempty(ext)
                matName=matName+".mat";
            end

            target=i_searchPrivateFolder(factory.Node,matName);
            if~target.Resolved
                target=matlabAnalyzer.findFile(matName,{});
            end

            refs=Reference(ref.Workspace,target,arg.Line,arg.Position,"FunctionArgument");

            if target.Resolved
                path=target.Location{1};
                [~,~,ext]=fileparts(path);
                if strcmpi(ext,'.mat')

                    try
                        vars=dependencies.internal.analysis.readVariables(path);
                        ref.Workspace.addVariables(vars);
                    catch ME
                        factory.warning(ME.identifier,ME.message,num2str(arg.Line));
                    end
                end
            end
        end

    end

end

function arg=i_select_input(args)
    for arg=args
        if isNotAnOptionArg(arg.Value)
            return;
        end
    end
    arg=dependencies.internal.analysis.matlab.Symbol.empty;
end

function flag=isNotAnOptionArg(argValue)
    flag=~ismember(argValue,{'-mat','-ascii','-regexp'});
end

function target=i_searchPrivateFolder(node,matName)
    folder=fileparts(node.Location{1});
    path=fullfile(folder,"private",matName);
    target=dependencies.internal.graph.Node.createFileNode(path);
end

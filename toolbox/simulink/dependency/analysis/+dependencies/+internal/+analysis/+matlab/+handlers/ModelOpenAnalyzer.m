classdef ModelOpenAnalyzer<dependencies.internal.analysis.matlab.FunctionAnalyzer




    properties(SetAccess=immutable)
        Functions=i_getAllSupportedFunctions();
        MinimumArguments=1;
        StringArguments=1;
        AllowedArguments=["gcb","gcs","bdroot"];
    end

    properties(Constant)
        ModelFunctions=["sim","load_system","close_system","open_system","get_param","set_param","Simulink.SimulationInput"];
        BlockFunctions=["delete_block","open_system","get_param","set_param"];
    end

    methods

        function refs=analyze(~,~,ref,~)
            import dependencies.internal.analysis.matlab.Reference;
            import dependencies.internal.analysis.findSymbol;


            arg=ref.InputArguments(1);
            path=arg.Value;
            node=findSymbol(path);


            if~node.Resolved&&i_funcSupportsBlocks(ref.Function.Value)
                model=strtok(path,'/');
                root=findSymbol(model);
                if root.Resolved
                    node=root;
                end
            end


            refs=Reference(ref.Workspace,node,arg.Line,arg.Position,'FunctionArgument');
        end

    end

end

function allFunctions=i_getAllSupportedFunctions()
    import dependencies.internal.analysis.matlab.handlers.ModelOpenAnalyzer;
    allFunctions=unique([ModelOpenAnalyzer.ModelFunctions,...
    ModelOpenAnalyzer.BlockFunctions]);
end

function blocksAreAccepted=i_funcSupportsBlocks(func)
    import dependencies.internal.analysis.matlab.handlers.ModelOpenAnalyzer;
    blocksAreAccepted=any(strcmp(func,ModelOpenAnalyzer.BlockFunctions));
end

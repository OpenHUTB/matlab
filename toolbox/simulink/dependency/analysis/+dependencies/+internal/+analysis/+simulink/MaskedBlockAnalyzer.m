classdef MaskedBlockAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        MaskInitializationType='BlockCallback,MaskInitialization';
        MaskDisplayType='BlockCallback,MaskDisplay';
        MaskCallbackType='BlockCallback,MaskCallbackString';
    end

    properties(Constant,Hidden)
        MaskDisplayFunctions={...
        'color','disp','dpoly','droots','fprintf',...
        'patch','plot','port_label','text','hide_arrows','block_icon'};
        MaskFunctionAnalyzers=dependencies.internal.analysis.simulink.MaskedImageFunctionAnalyzer;
    end

    methods

        function this=MaskedBlockAnalyzer()
            import dependencies.internal.analysis.simulink.queries.MaskParameterQuery

            queries.Name=MaskParameterQuery("Name");
            queries.Initialization=MaskParameterQuery("Initialization");
            queries.Display=MaskParameterQuery("Display");
            queries.Callback=MaskParameterQuery("Callback");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;


            nameMap=i_createNameMap(matches.Name);
            initMap=i_createMap(matches.Initialization);
            dispMap=i_createMap(matches.Display);


            blocks=unique([initMap.keys,dispMap.keys,matches.Name.BlockPath]);
            maskDeps=repmat({dependencies.internal.graph.Dependency.empty},size(blocks));
            for n=1:length(blocks)
                block=blocks{n};
                blockComp=Component.createBlock(node,block,handler.getSID(block));
                blockDeps=dependencies.internal.graph.Dependency.empty(1,0);


                workspace=dependencies.internal.analysis.matlab.Workspace;


                if nameMap.isKey(block)
                    vars=nameMap(block);
                    workspace.addVariables(vars);
                end


                if initMap.isKey(block)
                    factory=dependencies.internal.analysis.DependencyFactory(...
                    handler,blockComp,this.MaskInitializationType);
                    newDeps=handler.Analyzers.MATLAB.analyze(initMap(block),factory,workspace);
                    blockDeps=[blockDeps,newDeps];%#ok<AGROW>
                end


                if dispMap.isKey(block)
                    factory=dependencies.internal.analysis.DependencyFactory(...
                    handler,blockComp,this.MaskDisplayType);


                    dispWorkspace=dependencies.internal.analysis.matlab.Workspace.createChildWorkspace(workspace,"");
                    dispWorkspace.addFunctions(this.MaskDisplayFunctions);

                    newDeps=handler.Analyzers.MATLAB.analyze(dispMap(block),factory,dispWorkspace,this.MaskFunctionAnalyzers);
                    blockDeps=[blockDeps,newDeps];%#ok<AGROW>
                end


                blkWorkspace=handler.getWorkspace(block);
                blkWorkspace.addVariables(workspace.Variables);
                blkWorkspace.Scope=dependencies.internal.analysis.matlab.Scope.Mask;

                maskDeps{n}=blockDeps;
            end


            callbackDeps=repmat({dependencies.internal.graph.Dependency.empty},size(matches.Callback));
            for n=1:numel(matches.Callback)
                blockPath=matches.Callback(n).BlockPath;
                blockComp=Component.createBlock(node,blockPath,handler.getSID(blockPath));
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,blockComp,this.MaskCallbackType);
                callbackDeps{n}=handler.Analyzers.MATLAB.analyze(matches.Callback(n).Value,factory);
            end

            deps=[maskDeps{:},callbackDeps{:}];
        end

    end

end


function map=i_createNameMap(matches)
    map=containers.Map;
    for match=matches
        if map.isKey(match.BlockPath)
            map(match.BlockPath)=[map(match.BlockPath),match.Value];
        else
            map(match.BlockPath)=match.Value;
        end
    end
end

function map=i_createMap(matches)
    if isempty(matches)
        map=containers.Map;
    else
        map=containers.Map([matches.BlockPath],[matches.Value]);
    end
end

classdef ObserverReferenceAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        ObserverBlockType='ObserverReference';
    end

    methods

        function this=ObserverReferenceAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery;

            queries.ObserverModelName=createParameterQuery('ObserverModelName','BlockType','ObserverReference');
            queries.AllBlocks=createParameterQuery('Name','BlockType','ObserverReference');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            import dependencies.internal.graph.Type;


            models=[matches.ObserverModelName.Value];
            paths=[matches.ObserverModelName.BlockPath];

            blocksUsingDefaultObserverModelName=setdiff(matches.AllBlocks.BlockPath,paths);

            if~isempty(blocksUsingDefaultObserverModelName)
                paths=[paths,blocksUsingDefaultObserverModelName];
                defaultObserverModelName=get_param('built-in/ObserverReference','ObserverModelName');
                models=[models,repmat(defaultObserverModelName,1,length(blocksUsingDefaultObserverModelName))];
            end


            deps=dependencies.internal.graph.Dependency.empty;
            derivedExtensions=[".slxp",".mdlp"];
            for n=1:length(models)
                if(node.Type==Type.TEST_HARNESS)&&strcmp(models{n},'$systembd')

                    target=dependencies.internal.graph.Node.createFileNode(node.Location{1});
                else
                    [~,name]=fileparts(models{n});
                    target=handler.Analyzers.Simulink.resolve(node,name);
                end

                blockComp=Component.createBlock(node,paths{n},handler.getSID(paths{n}));
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,blockComp,this.ObserverBlockType,[".slx",".mdl"],derivedExtensions);
                newDeps=factory.create(target);
                if endsWith(models{n},derivedExtensions)&&length(newDeps)>=2
                    newDeps=newDeps(2);
                end
                deps=[deps,newDeps];%#ok<AGROW>
            end
        end

    end

end

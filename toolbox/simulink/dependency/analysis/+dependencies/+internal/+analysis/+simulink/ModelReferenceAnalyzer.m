classdef ModelReferenceAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        ModelReferenceType='ModelReference';
    end

    methods

        function this=ModelReferenceAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.AllBlocks=createParameterQuery('Name','BlockType','ModelReference');
            queries.ModelName=createParameterQuery('ModelNameDialog','BlockType','ModelReference');
            queries.Variants=createParameterQuery('Array[PropName="Variants"]/MATStruct/ModelName','BlockType','ModelReference','Variant','on');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            import dependencies.internal.graph.Type;


            models=[matches.ModelName.Value,matches.Variants.Value];
            paths=[matches.ModelName.BlockPath,matches.Variants.BlockPath];


            blocksUsingDefaultModelName=setdiff(matches.AllBlocks.BlockPath,paths);
            if~isempty(blocksUsingDefaultModelName)
                defaultModelName=get_param('built-in/ModelReference','ModelName');
                paths=[paths,blocksUsingDefaultModelName];
                models=[models,repmat({defaultModelName},1,length(blocksUsingDefaultModelName))];
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
                path=paths{n};
                if any(strcmp(path,matches.Variants.BlockPath))
                    path=path+"/"+models{n};
                end

                blockComp=Component.createBlock(node,path,handler.getSID(path));
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,blockComp,this.ModelReferenceType,[".slx",".mdl"],derivedExtensions);
                newDeps=factory.create(target);
                if endsWith(models{n},derivedExtensions)&&length(newDeps)>=2
                    newDeps=newDeps(2);
                end
                deps=[deps,newDeps];%#ok<AGROW>
            end
        end

    end

end

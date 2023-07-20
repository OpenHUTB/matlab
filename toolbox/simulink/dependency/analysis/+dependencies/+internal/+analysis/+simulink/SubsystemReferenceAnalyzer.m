classdef SubsystemReferenceAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SubsystemReferenceType='SubsystemReference';
    end

    methods

        function this=SubsystemReferenceAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.ModelName=createParameterQuery('ReferencedSubsystem','BlockType','SubSystem');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            import dependencies.internal.graph.Type;


            models=[matches.ModelName.Value];
            paths=[matches.ModelName.BlockPath];


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
                handler,blockComp,this.SubsystemReferenceType,[".slx",".mdl"],derivedExtensions);
                newDeps=factory.create(target);
                if endsWith(models{n},derivedExtensions)&&length(newDeps)>=2
                    newDeps=newDeps(2);
                end
                deps=[deps,newDeps];%#ok<AGROW>
            end
        end

    end

end

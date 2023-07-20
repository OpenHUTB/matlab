classdef SimscapeAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SimscapeType='Simscape';
        SimscapeComponentType='SimscapeComponent';
    end

    methods

        function this=SimscapeAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.SimscapeBlock=createParameterQuery('SourceFile','BlockType','SimscapeBlock');
            queries.SimscapeComponentBlock=createParameterQuery('SourceFile','BlockType','SimscapeComponentBlock');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            blocks=[matches.SimscapeBlock.BlockPath,matches.SimscapeComponentBlock.BlockPath];
            files=[matches.SimscapeBlock.Value,matches.SimscapeComponentBlock.Value];


            for n=1:length(files)
                source=files{n};
                if~isempty(source)
                    component=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));
                    factory=dependencies.internal.analysis.DependencyFactory(...
                    handler,component,this.SimscapeComponentType,".ssc",".sscp");

                    target=handler.Resolver.findSymbol(node,source);
                    deps=[deps,factory.create(target)];%#ok<AGROW>
                end
            end


            [folder,mdlname]=fileparts(node.Location{1});
            split=regexp(mdlname,'_lib$','split');
            if length(split)>1&&exist(fullfile(folder,['+',split{1}]),'dir')

                oldPwd=pwd;
                cleanup=onCleanup(@()cd(oldPwd));
                cd(folder);


                files=simscape.dependency.lib(...
                mdlname(1:end-4),simscape.DependencyType.All,node.Location{1},false,false);




                for n=1:length(files)
                    [~,depname]=fileparts(files{n});
                    if any(strcmp(depname,{'lib','sl_postprocess'}))
                        libfile=dependencies.internal.graph.Node.createFileNode(files{n});
                        deps(end+1)=dependencies.internal.graph.Dependency(...
                        node,'',libfile,'',this.SimscapeType);%#ok<AGROW>
                    end
                end
            end
        end

    end

end

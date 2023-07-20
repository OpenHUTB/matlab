classdef SimscapeNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        SimscapeType='Simscape';
        Extensions=".ssc";
    end

    methods

        function deps=analyze(this,handler,node)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;


            [files,missing]=simscape.dependency.file(...
            node.Location{1},simscape.DependencyType.All,false,true);


            for n=1:length(files)
                if~strcmp(files{n},node.Location{1})
                    factory=dependencies.internal.analysis.DependencyFactory(...
                    handler,Component.createRoot(node),this.SimscapeType,".ssc",".sscp");
                    target=dependencies.internal.graph.Node.createFileNode(files{n});
                    deps=[deps,factory.create(target)];%#ok<AGROW>
                end
            end


            for n=1:length(missing)
                target=dependencies.internal.graph.Node.createFileNode(missing{n});
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,'',target,'',this.SimscapeType);%#ok<AGROW>
            end
        end

    end

end

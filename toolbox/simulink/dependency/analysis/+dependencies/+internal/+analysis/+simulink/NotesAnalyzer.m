classdef NotesAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        NotesType='Notes';
    end

    methods

        function this=NotesAnalyzer()
            import dependencies.internal.analysis.simulink.queries.PluginQuery;
            queries.Notes=PluginQuery("NotesPlugin","Notes");
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            files=matches.Notes.Value;
            for file=files
                if file~=""
                    target=handler.Resolver.findFile(node,file,".mldatx");
                    deps(end+1)=dependencies.internal.graph.Dependency(...
                    node,"",target,"",this.NotesType);%#ok<AGROW>
                end
            end
        end

    end

end

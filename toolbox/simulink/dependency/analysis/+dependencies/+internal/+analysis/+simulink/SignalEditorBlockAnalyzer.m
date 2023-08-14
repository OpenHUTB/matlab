classdef SignalEditorBlockAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SignalEditorType=dependencies.internal.graph.Type("SignalEditor");
    end

    methods

        function this=SignalEditorBlockAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createInstanceDataParameterQuery;
            queries.SignalEditor=createInstanceDataParameterQuery('FileName','SourceBlock','SignalEditorBlockLib/Signal Editor');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            files=matches.SignalEditor.Value;
            blocks=matches.SignalEditor.BlockPath;

            deps=dependencies.internal.graph.Dependency.empty(1,0);
            for n=1:length(files)
                file=files{n};
                if~isempty(file)

                    [~,~,ext]=fileparts(file);
                    if isempty(ext)
                        file=[file,'.mat'];%#ok<AGROW>
                    end

                    target=handler.Resolver.findFile(file,{});
                    if~target.Resolved

                        relative=handler.Resolver.findFile(fullfile(pwd,file),{});
                        if relative.Resolved
                            target=relative;
                        end
                    end

                    upComp=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));
                    deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                    upComp,target,this.SignalEditorType);%#ok<AGROW>
                end
            end

        end

    end

end

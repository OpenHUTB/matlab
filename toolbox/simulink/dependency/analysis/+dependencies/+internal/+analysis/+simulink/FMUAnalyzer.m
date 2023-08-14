classdef FMUAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        FMUType=dependencies.internal.graph.Type("FMU");
    end

    methods

        function this=FMUAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery;

            queries.fmu=createParameterQuery('FMUName','BlockType','FMU');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            files=matches.fmu.Value;
            blocks=matches.fmu.BlockPath;

            for n=1:length(files)
                path=files{n};
                if~endsWith(path,'.fmu')
                    path=[path,'.fmu'];%#ok<AGROW>
                end

                target=handler.Resolver.findFile(node,path,".fmu");
                if~target.Resolved
                    fullpath=fullfile(pwd,path);
                    relTarget=dependencies.internal.analysis.findFile(fullpath,".fmu");
                    if relTarget.Resolved
                        target=relTarget;
                    end
                end

                blockComp=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));

                deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                blockComp,target,this.FMUType);%#ok<AGROW>
            end
        end

    end

end

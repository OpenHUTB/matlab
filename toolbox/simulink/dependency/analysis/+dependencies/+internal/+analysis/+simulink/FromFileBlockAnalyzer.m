classdef FromFileBlockAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        FromFileBlockType=dependencies.internal.graph.Type("FromFileBlock");
    end

    methods

        function this=FromFileBlockAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.FromFile=createParameterQuery('FileName','BlockType','FromFile');
            queries.AllBlocks=createParameterQuery('Name','BlockType','FromFile');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            files=matches.FromFile.Value;
            blocks=matches.FromFile.BlockPath;


            defaults=setdiff(matches.AllBlocks.BlockPath,blocks);
            defaultFileName=get_param('built-in/FromFile','FileName');
            if~isempty(defaults)
                files=[files,repmat({defaultFileName},1,length(defaults))];
                blocks=[blocks,defaults];
            end


            for n=1:length(files)
                file=files{n};
                if~isempty(file)


                    [~,~,ext]=fileparts(file);
                    if isempty(ext)
                        file=[file,'.mat'];%#ok<AGROW>
                    end

                    blockComp=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));


                    target=handler.Resolver.findFile(node,file,".mat");
                    if~target.Resolved

                        folder=fileparts(node.Path);
                        relative=handler.Resolver.findFile(node,fullfile(folder,file),".mat");
                        if relative.Resolved
                            target=relative;
                        end
                    end

                    deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                    blockComp,target,this.FromFileBlockType);%#ok<AGROW>
                end
            end

        end

    end

end

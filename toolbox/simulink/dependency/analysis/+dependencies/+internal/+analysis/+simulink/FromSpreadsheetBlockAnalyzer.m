classdef FromSpreadsheetBlockAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        FromSpreadsheetBlockType=dependencies.internal.graph.Type("FromSpreadsheetBlock");
    end

    methods

        function this=FromSpreadsheetBlockAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.FromSpreadsheet=createParameterQuery('FileName','BlockType','FromSpreadsheet');
            queries.AllBlocks=createParameterQuery('Name','BlockType','FromSpreadsheet');
            this.addQueries(queries);

        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            files=matches.FromSpreadsheet.Value;
            blocks=matches.FromSpreadsheet.BlockPath;


            defaults=setdiff(matches.AllBlocks.BlockPath,blocks);
            defaultFileName=get_param('built-in/FromSpreadsheet','FileName');
            if~isempty(defaults)
                files=[files,repmat({defaultFileName},1,length(defaults))];
                blocks=[blocks,defaults];
            end


            for n=1:length(files)
                target=handler.Resolver.findFile(node,files{n},{});
                if~target.Resolved

                    folder=fileparts(node.Path);
                    relative=handler.Resolver.findFile(node,fullfile(folder,files{n}),{});
                    if relative.Resolved
                        target=relative;
                    end
                end

                blockComp=Component.createBlock(node,blocks{n},handler.getSID(blocks{n}));

                deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                blockComp,target,this.FromSpreadsheetBlockType);%#ok<AGROW>
            end

        end

    end

end

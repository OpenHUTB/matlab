classdef LibraryLinksAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        LibraryLinkType=dependencies.internal.graph.Type("LibraryLink");
    end

    methods

        function this=LibraryLinksAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

            queries.LibraryLinks=createParameterQuery('SourceBlock','BlockType','Reference');
            queries.LinksToPorts=createParameterQuery('LibraryBlock');
            queries.Subsystems=createParameterQuery('TemplateBlock','BlockType','SubSystem');

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.graph.Component;


            links=[matches.LibraryLinks.Value,matches.LinksToPorts.Value];
            blocks=[matches.LibraryLinks.BlockPath,matches.LinksToPorts.BlockPath];


            if~isempty(matches.Subsystems.BlockPath)
                configLinks=matches.Subsystems.Value;
                configBlocks=matches.Subsystems.BlockPath;


                slashIdx=strfind(blocks,'/');
                numBlocks=length(blocks);
                parents=cell(numBlocks,1);
                for n=1:length(blocks)
                    parents{n}=blocks{n}(1:slashIdx{n}(end)-1);
                end
                libIdx=~ismember(parents,configBlocks);


                configIdx=contains(configLinks,'/');


                links=[links(libIdx),configLinks(configIdx)];
                blocks=[blocks(libIdx),configBlocks(configIdx)];
            end


            internalIdx=startsWith(links,'$bdroot/');
            links(internalIdx)=replaceBetween(links(internalIdx),1,7,handler.ModelInfo.BlockDiagramName);


            deps=dependencies.internal.graph.Dependency.empty(1,0);
            validDependencies=~strcmp(links,blocks);
            links=links(validDependencies);
            blocks=blocks(validDependencies);

            for n=1:length(links)
                model=strtok(links{n},'/');
                target=handler.Analyzers.Simulink.resolve(node,model);

                if~target.Resolved
                    [~,basecode]=slprivate('identify_library',model);
                    if basecode~=""
                        basecodes=strsplit(string(basecode),",");
                        missingNode=dependencies.internal.graph.Nodes.createProductNode(basecodes);
                        if~isempty(missingNode)
                            deps(end+1)=dependencies.internal.graph.Dependency.createToolbox(...
                            Component.createBlock(node,blocks{n},handler.getSID(blocks{n})),missingNode,this.LibraryLinkType);%#ok<AGROW>
                        end
                        continue;
                    end
                end

                deps(end+1)=dependencies.internal.graph.Dependency.createSource(...
                Component.createBlock(node,blocks{n},handler.getSID(blocks{n})),...
                Component.createBlock(target,links(n),""),this.LibraryLinkType);%#ok<AGROW>
            end

        end

    end

end

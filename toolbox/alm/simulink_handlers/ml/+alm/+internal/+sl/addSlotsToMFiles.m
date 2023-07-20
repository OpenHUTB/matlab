function addSlotsToMFiles(absoluteFilePath,art,graph)




    [~,bd,ext]=fileparts(art.Address);

    dgraph=getDependencyGraph(absoluteFilePath);

    for d=dgraph.Dependencies


        if~strcmp(d.UpstreamNode.Path,absoluteFilePath)
            continue
        end



        if~strcmp(d.UpstreamNode.Name,[bd,ext])
            continue
        end


        if d.DownstreamNode.Type~=dependencies.internal.graph.Type.FILE
            continue;
        end


        [~,~,fExt]=fileparts(d.DownstreamNode.Path);
        if~strcmp(fExt,'.m')
            continue;
        end


        qualifiedTo=d.DownstreamNode.Name;




        to=erase(d.DownstreamNode.Name,'.m');


        imports={};

        from=findArtifact(graph,art,bd,d.UpstreamComponent);
        createMATLABSlot(graph,from,to,qualifiedTo,imports);


    end
end

function SID=pathToSID(path)




    if contains(path,':')

        pathPart=extractBefore(path,':');


        sidPart=extractAfter(path,':');


        converted=extractAfter(Simulink.ID.getSID(pathPart),':');

        SID=strcat(converted,':',sidPart);
    else
        SID=extractAfter(Simulink.ID.getSID(path),':');
    end
end

function from=findArtifact(graph,art,bd,component)



    SID=component.SID;

    from=graph.getArtifactByAddress("",...
    art.getSelfContainedArtifact().Address,[bd,string(SID)]);

    if isempty(from)
        if contains(SID,':')


            while isempty(from)
                addr=strsplit(SID,':');
                if(length(addr)<2)
                    break;
                end

                SID=string(join(addr(1:end-1),':'));
                from=graph.getArtifactByAddress("",...
                art.getSelfContainedArtifact().Address,[bd,string(SID)]);
            end

        else

            blockPath=component.BlockPath;
            while(blockPath~="")&&isempty(from)

                blockPath=strsplit(blockPath,"/");
                blockPath=strjoin(blockPath(1:end-1),"/");

                if(blockPath~="")
                    SID=pathToSID(blockPath);
                    if~isempty(SID)
                        from=graph.getArtifactByAddress("",...
                        art.getSelfContainedArtifact().Address,[bd,string(SID)]);
                    end
                end
            end
        end
    end



    if(isempty(from))
        from=graph.getArtifactByAddress("",...
        art.getSelfContainedArtifact().Address,string(bd));
    end
end

function createMATLABSlot(graph,from,to,qualifiedTo,imports)


    b=alm.gdb.UnresolvedRelationshipBuilder.createMATLABSymbolRelationshipToFile(...
    from,alm.RelationshipType.REQUIRES,to,qualifiedTo,imports);
    b.createIntoGraph(graph);
end

function graph=getDependencyGraph(path)
    nodes=dependencies.internal.util.getNodes(path);

    modelAnalyzers=[
    dependencies.internal.analysis.simulink.EMLAnalyzer
    dependencies.internal.analysis.simulink.StateflowWorkspaceAnalyzer
    dependencies.internal.analysis.simulink.StateflowAnalyzer
    ];

    options=dependencies.internal.engine.AnalysisOptions;
    options.NodeAnalyzers=[
    dependencies.internal.analysis.simulink.SimulinkNodeAnalyzer(modelAnalyzers)
    ];

    graph=dependencies.internal.engine.analyze(nodes,options);
end

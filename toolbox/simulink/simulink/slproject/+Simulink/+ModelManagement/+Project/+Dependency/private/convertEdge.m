function dep=convertEdge(jUpVertex,jDownVertex,jEdge)




    upNode=convertVertex(jUpVertex);
    upComp=i_convertComponent(upNode,jEdge.getUpstreamComponent);
    downNode=convertVertex(jDownVertex);
    downComp=i_convertComponent(downNode,jEdge.getDownstreamComponent);
    depRel=i_getType(jEdge.getRelationshipType);
    depType=i_getType(jEdge.getReferenceType);

    harnessParts=regexp(upComp.Path,"^(.+)\|\|TestHarness\|\|(.+)$",'tokens');

    if~isempty(harnessParts)
        blockName=harnessParts{1}{1};
        upCompPath=harnessParts{1}{2};
        harnessName=strtok(upCompPath,"/");

        upNode=dependencies.internal.graph.Nodes.createTestHarnessNode(...
        upNode.Location{1},blockName,harnessName);

        upComp=dependencies.internal.graph.Component(...
        upNode,upCompPath,upComp.Type,upComp.LineNumber,upComp.EnclosingFunction,upCompPath,upComp.SID);
    end

    dep=dependencies.internal.graph.Dependency(upComp,...
    downComp,depType,depRel);
end

function component=i_convertComponent(node,jComponent)
    import dependencies.internal.graph.Component;
    if isempty(jComponent)
        component=Component.createRoot(node);
    else
        path=char(jComponent.getPath);
        type=i_getType(jComponent.getType);
        lineNumber=double(jComponent.getLineNumber);
        enclosingFunction=char(jComponent.getEnclosingFunction);
        blockPath=char(jComponent.getBlockPath);
        blockSID=char(jComponent.getSID);
        component=Component(node,path,type,lineNumber,enclosingFunction,blockPath,blockSID);
    end
end

function type=i_getType(jType)
    type=dependencies.internal.graph.Type(char(jType.getUUID));
end

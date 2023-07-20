function parentMap=diagramDFS(diagram)









    depthMap=containers.Map;
    parentMap=containers.Map;
    root=struct('uuid','0');
    for i=(1:numel(diagram.entities))
        e=diagram.entities(i);
        if isRoot(e)
            recurse(e,root,0,depthMap,parentMap);
        end
    end

end

function isRoot=isRoot(node)
    isRoot=true;
    for c=node.connections'
        if entitySrc(c)==node
            isRoot=false;
            return;
        end
    end
end

function src=entitySrc(connection)
    if isa(connection.source,'diagram.interface.Port')
        src=connection.source.parent;
    else
        src=connection.source;
    end
end

function dst=entityDst(connection)
    if isa(connection.destination,'diagram.interface.Port')
        dst=connection.destination.parent;
    else
        dst=connection.destination;
    end
end

function recurse(node,parent,depth,depthMap,parentMap)
    if depthMap.isKey(node.uuid)&&depthMap(node.uuid)>=depth
        return;
    end
    depthMap(node.uuid)=depth;
    parentMap(node.uuid)=parent.uuid;


    for c=node.connections'
        if entityDst(c)==node
            recurse(entitySrc(c),node,depth+1,depthMap,parentMap);
        end
    end
end
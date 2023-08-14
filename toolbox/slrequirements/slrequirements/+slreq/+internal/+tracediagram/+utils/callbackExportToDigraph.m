function out=callbackExportToDigraph(startingNode,nodes,edges)




    nodeList=jsondecode(nodes);
    edgeList=jsondecode(edges);
    startNode=jsondecode(startingNode);

    nodeInfo=collectNodeInfo(nodeList,startNode.Id);

    dg=createDigraph(edgeList,nodeInfo);





























    out=createVariable(startNode.Summary,dg);
end


function variableName=createVariable(varName,dg)
    variableStr=sprintf('%s_for_%s','graph',varName);
    variableName=matlab.lang.makeValidName(variableStr);
    assignin('base',variableName,dg);
end


function nodeInfo=collectNodeInfo(nodeList,startNodeId)


    layerInfo=containers.Map('valueType','double','keytype','double');
    nodeInfo=containers.Map('keyType','char','valueType','any');
    for index=1:length(nodeList)
        cNode=nodeList(index);
        if isKey(layerInfo,cNode.LayerDepth)
            layerInfo(cNode.LayerDepth)=layerInfo(cNode.LayerDepth)+1;
        else
            layerInfo(cNode.LayerDepth)=1;
        end
        nodeList(index).IndexInCurrentLayer=layerInfo(cNode.LayerDepth);
        nodeList(index).IsStartingNode=strcmp(startNodeId,cNode.Id);
        nodeInfo(cNode.Id)=nodeList(index);
    end

end

function dg=createDigraph(edgeList,nodeInfo)


    starts={};
    ends={};
    types={};
    hasChanged={};
    edgeLabels={};
    if~isempty(edgeList)
        starts={edgeList.SourceNodeId};
        ends={edgeList.DestinationNodeId};
        types={edgeList.LinkType};
        hasChanged={edgeList.HasChanged};
        edgeLabels={edgeList.Label};
    end

    dg=digraph(starts,ends);

    dg.Edges.Types=types';
    dg.Edges.HasChanged=hasChanged';
    dg.Edges.Labels=edgeLabels';



    dg=addExtraNodes(dg,nodeInfo.keys);


    dg=addNodeInfoIntoDigraph(dg,nodeInfo);
end


function dg=addNodeInfoIntoDigraph(dg,nodeInfo)
    allNodes=dg.Nodes.Name;
    names=cell(size(allNodes));


    streamType=cell(size(allNodes));
    layerDepth=cell(size(allNodes));
    indexInCurrentLayer=cell(size(allNodes));
    isStartingNode=cell(size(allNodes));


    for index=1:length(allNodes)
        cNode=allNodes{index};
        cNodeInfo=nodeInfo(cNode);
        names{index}=cNodeInfo.Summary;
        streamType{index}=cNodeInfo.StreamType;
        layerDepth{index}=cNodeInfo.LayerDepth;
        indexInCurrentLayer{index}=cNodeInfo.IndexInCurrentLayer;
        isStartingNode{index}=cNodeInfo.IsStartingNode;
    end

    dg.Nodes.Labels=names;
    dg.Nodes.LayerDepths=layerDepth;
    dg.Nodes.StreamTypes=streamType;
    dg.Nodes.isStartingNode=isStartingNode;
    dg.Nodes.IndexInCurrentLayer=indexInCurrentLayer;
end

function dg=addExtraNodes(dg,nodeList)
    allNodes=dg.Nodes.Name;
    extraNodes=setdiff(nodeList,allNodes);

    dg=dg.addnode(extraNodes);
end
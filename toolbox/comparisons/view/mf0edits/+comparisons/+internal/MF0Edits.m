classdef MF0Edits<handle&xmlcomp.internal.NodeAccessor



    properties(GetAccess=public)
Filters
LeftFileName
        LeftRoot xmlcomp.Node
RightFileName
        RightRoot xmlcomp.Node
TimeSaved
    end

    properties(GetAccess=public,Constant=true)
        Version='4.0';
    end

    methods(Access=public)
        function obj=MF0Edits(mf0EditsView)
            import comparisons.internal.Side2
            rootNodes=makeRootNodes();

            obj.LeftRoot=rootNodes(Side2.Left);
            obj.RightRoot=rootNodes(Side2.Right);

            nodeMap=containers.Map;
            makeNodeTrees(mf0EditsView.getForest(),rootNodes,nodeMap);

            for match=mf0EditsView.getMatches()
                setPartners(match,nodeMap);
                addParameters(match,mf0EditsView.getSubcomparison(match),nodeMap);
            end
        end
    end
end

function nodes=makeRootNodes()
    import comparisons.internal.Side2
    nodes=makeNodes();
    for side=enumeration('comparisons.internal.Side2')'
        nodes(side).BaseNode.Name='Root';
    end
    partnerNodes(nodes(Side2.Left),nodes(Side2.Right));
end

function nodes=makeNodes()
    nodes=[xmlcomp.Node(comparisons.internal.MF0NodeWrapper),...
    xmlcomp.Node(comparisons.internal.MF0NodeWrapper)];
end

function partnerNodes(node1,node2)
    node1.Partner=node2;
    node2.Partner=node1;
end

function makeNodeTrees(forest,rootNodes,nodeMap)
    rootEntries=forest.roots.toArray;
    queue=struct('MF0Entry',num2cell(rootEntries),...
    'ParentNodes',repmat({rootNodes},1,forest.roots.Size));

    while~isempty(queue)

        mf0Entry=queue(1).MF0Entry;
        parentNodes=queue(1).ParentNodes;
        queue(1)=[];


        nodes=makeNodes();
        optionalNodes=mf0Entry.nodes.toArray();
        for side=enumeration('comparisons.internal.Side2')'
            if~isempty(optionalNodes(side).node)
                node=xmlcomp.Node(...
                comparisons.internal.MF0NodeWrapper(optionalNodes(side).node));
                node.Parent=parentNodes(side);
                nodes(side)=node;
                nodeMap(optionalNodes(side).UUID)=node;
            end
        end


        children=mf0Entry.children.toArray();
        if~isempty(children)
            queue(end+1:end+length(children))=...
            struct('MF0Entry',num2cell(children),...
            'ParentNodes',repmat({nodes},1,length(children)));
        end
    end
end

function setPartners(match,nodeMap)
    import comparisons.internal.Side2
    optionalNodes=match.nodes.toArray();
    if all(arrayfun(@(x)~isempty(x.node),optionalNodes))
        partnerNodes(nodeMap(optionalNodes(Side2.Left).UUID),...
        nodeMap(optionalNodes(Side2.Right).UUID));
    end
end

function addParameters(match,parameterTable,nodeMap)
    if~isa(parameterTable,'comparisons.viewmodel.parameter.mfzero.ParameterTable')
        return
    end
    optionalNodes=match.nodes.toArray();
    for side=enumeration('comparisons.internal.Side2')'
        if~isempty(optionalNodes(side).node)
            node=nodeMap(optionalNodes(side).UUID);
            for paramEntry=parameterTable.entries.toArray()
                optionalParams=paramEntry.parameters.toArray();
                addParameter(node,optionalParams(side));

            end
        end
    end
end

function addParameter(node,optionalParam)
    param=optionalParam.parameter;
    if~isempty(param)
        node.BaseNode.Parameters=[node.Parameters,...
        struct('Name',param.name,...
        'Value',param.value)];
    end
end

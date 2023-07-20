function nodeIdx=getNodesUnderRoot(this)
    if~isempty(this.RootCompId)
        rootMAObj=this.getMAObjs(this.RootCompId);

        nodeIdx=getNodesIndices(rootMAObj{1}.TaskAdvisorRoot);
    else
        nodeIdx=[];
    end
end

function nodeIdx=getNodesIndices(node)
    nodeIdx=[];

    nodeIdx(end+1)=node.Index;

    if isa(node,'ModelAdvisor.Group')

        for n=1:length(node.ChildrenObj)

            tmpIdx=getNodesIndices(node.ChildrenObj{n});

            nodeIdx=[nodeIdx,tmpIdx];%#ok<AGROW>

        end
    end
end
function nodeIds=getNodesForRoot(this,rootName,linkedOnly)




    nodeIds={};
    srcRoot=rmimap.RMIRepository.getRoot(this.graph,rootName);
    if isempty(srcRoot)
        return;
    end
    if srcRoot.nodes.size>0
        nodeIds=cell(1,srcRoot.nodes.size);
        skipIdx=false(size(nodeIds));
        for i=1:srcRoot.nodes.size
            nodeIds{i}=srcRoot.nodes.at(i).id;
            if linkedOnly&&srcRoot.nodes.at(i).dependeeLinks.size==0
                skipIdx(i)=true;
            end
        end
        if linkedOnly&&any(skipIdx)
            nodeIds(skipIdx)=[];
        end
    end


    if srcRoot.dependeeLinks.size>0
        nodeIds=[{''},nodeIds];
    end
end



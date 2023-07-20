function[selectedNodes,nodePaths,labels]=...
    getSelectedNodes(tree,loggedNode)





    import simscape.logging.internal.*

    assert(numel(loggedNode)==1,'The input node to getSelectedNodes should be scalar');

    selectedTreeNodes=tree.getSelectedNodes;
    selectionPaths=tree.getTree.getSelectionPaths;
    assert(numel(selectedTreeNodes)==numel(selectionPaths),...
    getMessageFromCatalog('IncorrectSelectedNodes'));

    numSelected=numel(selectedTreeNodes);
    selectedNodes=cell(1,numSelected);
    nodePaths=cell(1,numSelected);
    pathLabels=cell(1,numSelected);


    for idx=1:numSelected
        nodePaths{idx}=indexedPath(selectedTreeNodes(idx));
        selectedNodes{idx}=indexedNode(loggedNode,nodePaths{idx});
        pathLabels{idx}=indexedPathLabel(nodePaths{idx});
    end


    [pathLabels,sortIdx]=sort(pathLabels);
    nodePaths=nodePaths(sortIdx);
    selectedNodes=selectedNodes(sortIdx);


    ids=cellfun(@(x)(x.id),selectedNodes,'UniformOutput',false);



    labels=ids;




    uniqueIds=unique(ids);
    if numel(uniqueIds)~=numel(ids)
        for idx=1:numel(uniqueIds)
            i=strcmp(ids,uniqueIds{idx});


            if numel(find(i))>1
                labels(i)=pathLabels(i);
            end
        end

    end

end

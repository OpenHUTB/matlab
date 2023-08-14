function addedNodes=initTrees(obj,usedIdMap)




    addedNodes={};
    allData=usedIdMap.values;

    for idx=1:numel(allData)
        data=allData{idx};

        childIds=data.aggregatedIds;
        if isempty(childIds)
            continue;
        end

        pnode=cvi.ResultsExplorer.Node.create(data,obj.root.passiveTree);
        obj.root.passiveTree.addNodeToRoot(pnode);
        usedIdMap.remove(data.uniqueId);

        for idxc=1:numel(childIds)
            uId=childIds{idxc};
            if usedIdMap.isKey(uId)
                data=usedIdMap(uId);
                usedIdMap.remove(uId);
                newNode=cvi.ResultsExplorer.Node.create(data,obj.root.passiveTree);
                pnode.addChild(newNode);
            end
        end
    end
    allIds=usedIdMap.keys;
    for idx=1:numel(allIds)
        data=usedIdMap(allIds{idx});
        node=cvi.ResultsExplorer.Node.create(data,obj.root.passiveTree);
        obj.root.passiveTree.addNodeToRoot(node);
        addedNodes{end+1}=node;%#ok<AGROW>
    end

end
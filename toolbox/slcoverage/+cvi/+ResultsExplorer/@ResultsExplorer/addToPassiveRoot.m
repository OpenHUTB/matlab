
function node=addToPassiveRoot(obj,data)




    if isempty(data)
        return;
    end
    node=cvi.ResultsExplorer.Node.create(data,obj.root.passiveTree);
    obj.root.passiveTree.addNodeToRoot(node);
    childIds=data.getCvd().aggregatedIds;
    if~isempty(childIds)
        for idxc=1:numel(childIds)
            uId=childIds{idxc};
            data=obj.getDataByUniqueId(uId);
            if~isempty(data)
                newNode=cvi.ResultsExplorer.Node.create(data,obj.root.passiveTree);
                node.addChild(newNode);
            end
        end
    end

end
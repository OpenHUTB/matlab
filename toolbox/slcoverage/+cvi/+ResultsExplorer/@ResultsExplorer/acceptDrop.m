function tf=acceptDrop(obj,acceptNode,dropNode)




    tf=true;
    try
        acceptTree=getNodeTree(obj,acceptNode);
        if acceptTree==0
            return;
        end

        if(acceptTree.isActive)
            if numel(dropNode.children)>1
                newNode=obj.root.passiveTree.copyTreeNode(dropNode.children,obj.root.activeTree);
            else
                newNode=obj.root.passiveTree.copyTreeNode({dropNode},obj.root.activeTree);
            end
            if~isempty(obj.root.activeTree.root.data)
                obj.root.activeTree.root.data.needSave=true;
            end
            obj.root.activeTree.needAggregate=true;
            obj.imme.expandTreeNode(obj.root.activeTree.interface);
            obj.imme.selectTreeViewNode(newNode.interface);
            newNode.data.getCvd();
        else
            obj.root.passiveTree.removeTreeNode({dropNode});

        end
        obj.root.activeTree.needAggregate=true;
    catch MEx
        display(MEx.stack(1));
    end
end
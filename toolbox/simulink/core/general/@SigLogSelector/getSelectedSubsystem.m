function[node,listItems]=getSelectedSubsystem()





    me=SigLogSelector.getExplorer;
    node=me.imme.getCurrentTreeNode;


    if nargout>1
        listItems=me.imme.getSelectedListNodes;
        if length(listItems)>1
            listItems=[listItems{:}]';
        end
    end
end

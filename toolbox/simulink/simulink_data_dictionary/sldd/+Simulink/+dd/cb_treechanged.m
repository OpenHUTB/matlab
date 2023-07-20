function cb_treechanged(id,select)



    root=DAStudio.Root;
    actions=find(root,'-isa','DAStudio.Action');

    thisAction=[];
    for i=1:length(actions)
        if actions(i).id==id
            thisAction=actions(i);
            break;
        end
    end

    if isempty(thisAction)||isempty(thisAction.callbackData)
        return;
    end;

    rootAdapter=thisAction.callbackData.rootAdapter;
    h=rootAdapter.UserData.me;



    imme=DAStudio.imExplorer;
    imme.setHandle(h);
    if select
        treeNode=h.getTreeSelection();
        imme.selectListViewNode(treeNode.getChildren());
    else
        imme.selectListViewNode();
    end
end
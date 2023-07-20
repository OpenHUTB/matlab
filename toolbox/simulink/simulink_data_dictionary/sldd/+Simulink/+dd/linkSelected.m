function linkSelected(id,mode)

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


    me=rootAdapter.UserData.me;
    treeNode=me.getTreeSelection();

    rootAdapter.assignDictionaryBtn(treeNode.MyModelLink.DataDictionary,mode);
end
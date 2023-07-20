function cm=getContextMenu(handle,selectedNode)




    cm='';
    me=TflDesigner.getexplorer;

    if~isempty(me)
        cm=me.getcontextmenu(handle,selectedNode);
    end

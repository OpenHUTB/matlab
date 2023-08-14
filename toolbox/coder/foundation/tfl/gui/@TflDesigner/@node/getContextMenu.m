function cm=getContextMenu(this,selectedNode)




    cm='';
    me=TflDesigner.getexplorer;

    if~isempty(me)
        if strcmp(class(this),'TflDesigner.node')
            me.imme.selectListViewNode(this);
        end
        cm=me.getcontextmenu(this,selectedNode);
    end

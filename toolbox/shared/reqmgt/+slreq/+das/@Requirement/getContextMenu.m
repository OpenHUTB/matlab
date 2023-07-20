function menu=getContextMenu(this,nodes)%#ok<INUSD>

    items=this.getContextMenuItems('standalone');
    menu=this.view.requirementsEditor.createContextMenu(items);
end

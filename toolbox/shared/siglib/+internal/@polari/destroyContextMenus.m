function destroyContextMenus(p)

    delete(p.UIContextMenu_Master);
    delete(p.UIContextMenu_AngleTicks);
    delete(p.UIContextMenu_MagTicks);
    delete(p.UIContextMenu_Grid);
    delete(p.UIContextMenu_Data);
    p.UIContextMenu_Master=[];
    p.UIContextMenu_AngleTicks=[];
    p.UIContextMenu_MagTicks=[];
    p.UIContextMenu_Grid=[];
    p.UIContextMenu_Data=[];

function createGridContextMenu(p,hParent)






    hc=hParent;







    Nc=numel(hc.Children);
    if Nc==1
        hDummy=hc.Children;
    else
        hDummy=[];
    end

    make=Nc<2;
    sep=false;


    internal.ContextMenus.createContextSubmenu(p,make,sep,hc,...
    '',p.GridTypeValues,'GridType');
    hk=internal.ContextMenus.createContextMenuChecked(p,make,sep,hc,...
    'Grid Over Data','GridOverData');
    set(hk,'Separator','on');
    hl=internal.ContextMenus.createContextMenuChecked(p,make,sep,hc,...
    'Clip Data','ClipData');
    set(hl,'Separator','on');

    if make&&~isempty(hDummy)
        delete(hDummy);
    end

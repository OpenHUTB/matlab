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
    internal.ContextMenus.createContextMenuChecked(p,make,sep,hc,...
    'Clip Data','ClipData');
    internal.ContextMenus.createContextMenuChecked(p,make,sep,hc,...
    'Zero-Angle Line','ZeroAngleLine');
    internal.ContextMenus.createContextMenuChecked(p,make,true,hc,...
    'Draw Grid to Origin','DrawGridToOrigin');
    internal.ContextMenus.createContextMenuChecked(p,make,sep,hc,...
    'Grid Over Data','GridOverData');
    internal.ContextMenus.createContextMenuChecked(p,make,sep,hc,...
    'Grid Auto-Refinement','GridAutoRefinement');
    internal.ContextMenus.createContextMenuChecked(p,make,sep,hc,...
    'Show Grid','GridVisible');

    if make&&~isempty(hDummy)
        delete(hDummy);
    end

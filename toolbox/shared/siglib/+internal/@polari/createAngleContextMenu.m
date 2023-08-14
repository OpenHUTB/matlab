function createAngleContextMenu(p,hParent)









    topLevel=nargin<2;
    if topLevel
        hc=p.UIContextMenu_AngleTicks;
    else
        hc=hParent;
    end







    Nc=numel(hc.Children);
    if Nc==1
        hDummy=hc.Children;
    else
        hDummy=[];
    end
    make=Nc<2;

    if make
        opts={hc,'<html><b>ANGLE</b></html>','','Enable','off'};
        internal.ContextMenus.createContext(opts);
    end





    addSep=true;
    internal.ContextMenus.createContextSubmenu(p,make,addSep,hc,...
    '',{'CW','CCW'},'AngleDirection');




    internal.ContextMenus.createContextSubmenu(p,make,true,hc,...
    'Tick Format',{'180','360'},'AngleTickLabelFormat');
    internal.ContextMenus.createContextSubmenu(p,make,false,hc,...
    'Resolution',p.AngleResValueStrs,...
    'AngleResolution',p.AngleResValues);







    internal.ContextMenus.createContextMenuChecked(p,make,false,hc,...
    'Rotate Tick Labels','AngleTickLabelRotation');







    if make&&~isempty(hDummy)
        delete(hDummy);
    end

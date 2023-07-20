function createMagnitudeContextMenu(p,hParent)









    topLevel=nargin<2;
    if topLevel
        hc=p.UIContextMenu_MagTicks;
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
        opts={hc,'<html><b>MAGNITUDE</b></html>','','Enable','off'};
        internal.ContextMenus.createContext(opts);
    end





    addSep=true;
    internal.ContextMenus.createContextMenuAuto(p,make,addSep,hc,...
    'Auto Limits','MagnitudeLimMode');
    internal.ContextMenus.createContextMenuAuto(p,make,false,hc,...
    'Auto Ticks','MagnitudeTickMode');
    internal.ContextMenus.createContextMenuAuto(p,make,false,hc,...
    'Auto Axis Angle','MagnitudeAxisAngleMode');



    if make
        internal.ContextMenus.createContext({hc,'Properties...',...
        @(h,~)internal.polariMBMagTicks.openPropertyEditor(p),'separator','on'});
        internal.ContextMenus.createContext({hc,'Reset to defaults',...
        @(h,~)m_MagResetToDefaults(p),'separator','on'});
    end

    if make&&~isempty(hDummy)
        delete(hDummy);
    end

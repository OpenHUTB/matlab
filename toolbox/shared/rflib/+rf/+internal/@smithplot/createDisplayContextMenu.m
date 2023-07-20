function createDisplayContextMenu(p,hParent)











    topLevel=nargin<2;
    if topLevel
        hc=p.UIContextMenu_Grid;
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
        if isa(p.Parent,'matlab.ui.Figure')
            opts={hc,'<html><b>DISPLAY</b></html>','','Enable','off'};
        else
            opts={hc,'DISPLAY','','Enable','off'};
        end
        internal.ContextMenus.createContext(opts);
    end


    if make
        hGrid=internal.ContextMenus.createContext({hc,'Grid','','separator','on'});
        hGrid.Callback=@(h,e)createGridContextMenu(p,hGrid);

        internal.ContextMenus.createContext({hGrid,'',[]});
    end


    addLegendMenus(p,hc,make);


    hm=internal.ContextMenus.createContextSubmenu(p,make,false,hc,...
    'View',p.ViewValues,'View');
    set(hm([2,6]),'Separator','on');

    if make&&~isempty(hDummy)
        delete(hDummy);
    end

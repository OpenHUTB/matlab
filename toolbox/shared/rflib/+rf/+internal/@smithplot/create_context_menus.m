function create_context_menus(p)






    try

        hc=uicontextmenu(...
        'Parent',p.hFigure,...
        'HandleVisibility','off');
        p.UIContextMenu_Grid=hc;
        hc.Callback=@(h,e)createDisplayContextMenu(p);


        hc=uicontextmenu(...
        'Parent',p.hFigure,...
        'HandleVisibility','off');
        p.UIContextMenu_Data=hc;
        hc.Callback=@(h,e)createDataContextMenu(p);

        set(p.Parent,'uicontextmenu',p.UIContextMenu_Master);
    catch
    end



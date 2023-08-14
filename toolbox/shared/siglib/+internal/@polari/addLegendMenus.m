function addLegendMenus(p,hc,make)







    if isempty(hc)
        return
    end


    if make

        opts={hc,'Titles','','separator','on'};
        hp=internal.ContextMenus.createContext(opts);
        internal.ContextMenus.createContext({hp,'Dummy',''});
        hp.Callback=@(h,~)createTitlesContextMenu(p,h);
        hp.UserData='TitleParent';
    end


    if make
        opts={hc,'Show Legend',@(h,~)m_toggleLegend(p)};
        h=internal.ContextMenus.createContext(opts);
    else
        h=findobj(hc,'label','Show Legend');
    end

    set(h,'Checked',internal.LogicalToOnOff(p.pLegend));


    internal.ContextMenus.createContextMenuChecked(p,make,false,hc,...
    'Tool Tips','ToolTips');



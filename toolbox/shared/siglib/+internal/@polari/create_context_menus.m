function create_context_menus(p)






    hc=p.UIContextMenu_Master;
    if isempty(hc)




        hc=uicontextmenu(...
        'Parent',p.hFigure,...
        'HandleVisibility','off');
        hc.Callback=@(h,e)updateMainContextMenu(p,hc);
        p.UIContextMenu_Master=hc;

        opts={hc,'<html><b>MAIN</b></html>','','Enable','off'};
        internal.ContextMenus.createContext(opts);












        datasetIndex=[];
        ToggleStatus='On';
        if~builtin('license','test','Antenna_Toolbox')
            ToggleStatus='Off';
        end
        h1=internal.ContextMenus.createContext({hc,...
        'Antenna Metrics',@(~,~)m_ToggleAntennaMetrics(p,datasetIndex),...
        'separator','on','Visible',ToggleStatus});
        h1.Checked=internal.LogicalToOnOff(p.AntennaMetrics);


        h2=internal.ContextMenus.createContext({hc,'Clean Data','',...
        'separator','on'});
        h2.Callback=@(h2,~)cleanData(p);

        hp=internal.ContextMenus.createContext({hc,'Measurements','','separator','on'});
        internal.ContextMenus.createContext({hp,'Dummy',''});
        hp.Callback=@(h,~)createMeasurementContextMenu(p,h,[]);
        hp.UserData='MeasurementParent';


        hAngle=internal.ContextMenus.createContext({hc,'Angle','','separator','off'});
        hAngle.Callback=@(h,e)createAngleContextMenu(p,hAngle);
        internal.ContextMenus.createContext({hAngle,'Dummy',[]});


        hMag=internal.ContextMenus.createContext({hc,'Magnitude',''});
        hMag.Callback=@(h,e)createMagnitudeContextMenu(p,hMag);
        internal.ContextMenus.createContext({hMag,'Dummy',[]});


        hGrid=internal.ContextMenus.createContext({hc,'Display',''});
        hGrid.Callback=@(h,e)createDisplayContextMenu(p,hGrid);
        internal.ContextMenus.createContext({hGrid,'Dummy',[]});























        hc=uicontextmenu(...
        'Parent',p.hFigure,...
        'HandleVisibility','off');
        p.UIContextMenu_AngleTicks=hc;
        hc.Callback=@(h,e)createAngleContextMenu(p);


        hc=uicontextmenu(...
        'Parent',p.hFigure,...
        'HandleVisibility','off');
        p.UIContextMenu_MagTicks=hc;
        hc.Callback=@(h,e)createMagnitudeContextMenu(p);


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




    else




        make=false;
        topLevel=false;
        addMeasurementAndLegendMenus(p,hc,make,topLevel);
    end

    function updateMainContextMenu(p,hc)



        h1=hc.findobj('Label','Antenna Metrics','-depth',1);
        h1.Checked=internal.LogicalToOnOff(p.AntennaMetrics);

        h2=hc.findobj('Label','Clean Data','-depth',1);
        if~isempty(h2)
            flag=p.CleanData;
            h2.Checked=internal.LogicalToOnOff(flag);
            h2.Enable=internal.LogicalToOnOff(~flag);
        end

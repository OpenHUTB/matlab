function createMeasurementContextMenu(p,hp,markerParent)

















    hgObj=p.hFigure.CurrentObject;
    if isempty(hgObj)
        datasetIndex=[];
    else
        datasetIndex=getappdata(hgObj,'polariDatasetIndex');
    end
    parentIsDataset=~isempty(datasetIndex);
    if~parentIsDataset
        if isempty(markerParent)


            datasetIndex=[];
        else


            datasetIndex=getDataSetIndex(markerParent);
        end
    end
    isActiveTrace=isempty(datasetIndex);
    if isActiveTrace
        datasetIndex=p.pCurrentDataSetIndex;
    end




    hchild=hp.Children;
    if~isempty(hchild)
        delete(hchild(2:end));
        h1=hchild(1);
        delete(h1.Children);
    end




    label=sprintf('<html><b>DATASET %d</b></html>',datasetIndex);
    if isActiveTrace
        label=[label,' (ACTIVE)'];
    end
    h1.Label=label;
    h1.Tag=h1.Label;
    h1.Separator='off';
    h1.Checked='off';
    h1.Callback='';
    h1.Enable='off';


    opts={hp,'Add Cursor',@(~,~)m_addCursor(p,datasetIndex),'separator','on'};
    internal.ContextMenus.createContext(opts);






    opts={hp,'Remove Cursors',[]};
    hrc=internal.ContextMenus.createContext(opts);
    opts={hrc,'From This Dataset',@(~,~)removeAllCursors(p,datasetIndex)};
    internal.ContextMenus.createContext(opts);
    opts={hrc,'From All Datasets',@(~,~)removeAllCursors(p,'all')};
    internal.ContextMenus.createContext(opts);



    opts={hp,'Angle Span',...
    @(~,~)m_ToggleSpans(p,markerParent),'separator','on'};

    hs=internal.ContextMenus.createContext(opts);
    isVis=p.Span;



    if p.AddMarkersToEnableSpanMode


        enableSpans=true;
    else










        enableSpans=isVis||...
        (numel(p.hPeakAngleMarkers)+...
        numel(p.hCursorAngleMarkers)>1);
    end
    hs.Checked=internal.LogicalToOnOff(isVis);
    hs.Enable=internal.LogicalToOnOff(enableSpans);



    opts={hp,'Peak Locations',''};
    h1=internal.ContextMenus.createContext(opts);
    h1.Callback=@(~,~)m_toggleUpdatePeaks(p,datasetIndex);












    peaksEnabled=~isempty(datasetIndex)&&...
    (numel(p.pPeaks)>=datasetIndex)&&...
    (p.pPeaks(datasetIndex)>0);
    h1.Checked=internal.LogicalToOnOff(peaksEnabled);



    ToggleStatus='On';
    if~builtin('license','test','Antenna_Toolbox')||isappdata(hp,'RFMetrics')
        ToggleStatus='Off';
    end
    h1=internal.ContextMenus.createContext({hp,...
    'Antenna Metrics',@(~,~)m_ToggleAntennaMetrics(p,datasetIndex),...
    'separator','on','Visible',ToggleStatus});

    if parentIsDataset



        a=p.hAntenna;
        val=~isempty(a)&&areLobesVisible(a,datasetIndex);
    else


        val=p.AntennaMetrics;
    end
    h1.Checked=internal.LogicalToOnOff(val);

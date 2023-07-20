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


    opts={hp,'Add Point',@(~,~)m_addCursor(p,datasetIndex),'separator','on'};
    internal.ContextMenus.createContext(opts);


























































































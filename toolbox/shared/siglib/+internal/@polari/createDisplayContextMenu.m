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
        opts={hc,'<html><b>DISPLAY</b></html>','','Enable','off'};
        internal.ContextMenus.createContext(opts);
    end

    if topLevel
        addMeasurementAndLegendMenus(p,hc,make,topLevel);
    else
        addLegendMenus(p,hc,make);
    end







...
...
...
...
...
...
...
...















    styleVals=p.StyleValues;
    styleVals(strcmpi(styleVals,'sectors'))=[];
    sep=true;
    ht=internal.ContextMenus.createContextSubmenu(p,make,sep,hc,...
    'Style',styleVals,'Style');

    is_intensity_data=isIntensityData(p);
    ht(1).Parent.Enable=internal.LogicalToOnOff(~is_intensity_data);


    sep=false;
    hm=internal.ContextMenus.createContextSubmenu(p,make,sep,hc,...
    'View',p.ViewValues,'View');
    set(hm([2,6]),'Separator','on');



    if make
        hGrid=internal.ContextMenus.createContext({hc,'Grid','','separator','off'});
        hGrid.Callback=@(h,e)createGridContextMenu(p,hGrid);
        internal.ContextMenus.createContext({hGrid,'Dummy',[]});
    end

    internal.ContextMenus.createContextMenuChecked(p,make,false,hc,...
    'Normalize Data','NormalizeData');

    if make&&~isempty(hDummy)
        delete(hDummy);
    end

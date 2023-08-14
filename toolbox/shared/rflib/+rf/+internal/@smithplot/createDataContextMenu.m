function createDataContextMenu(p,hParent)











    masterMenu=nargin>1;
    if~masterMenu
        hc=p.UIContextMenu_Data;
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





    if~masterMenu




        hData=p.hFigure.CurrentObject;
        datasetIndex=getappdata(hData,'smithiDatasetIndex');
    else
        datasetIndex=[];
    end
    if~masterMenu



        dTitle=sprintf('DATASET %d',datasetIndex);









        if isa(p.Parent,'matlab.ui.Figure')
            label=['<html><b>',dTitle,'</b></html>'];
        else
            label=dTitle;
        end

        if make
            opts={hc,label,'','Enable','off'};
            hTitle=internal.ContextMenus.createContext(opts);
            hTitle.UserData='titleEntry';
        else

            hTitle=findobj(hc,'UserData','titleEntry');
            assert(~isempty(hTitle));
            hTitle.Label=label;
        end
    end

    addSep=true;











    ht=internal.ContextMenus.createContextSubmenu(p,make,addSep,hc,...
    'Line style',p.LineStyleValues,...
    @(a,b,c,d)internal.polari.multiValueContextMenuCB(...
    a,b,c,d,datasetIndex,'LineStyle'));


    is_intensity_data=isIntensityData(p);
    ht(1).Parent.Enable=internal.LogicalToOnOff(~is_intensity_data);

    ht=internal.ContextMenus.createContextSubmenu(p,make,false,hc,...
    'Marker',p.MarkerValues,...
    @(a,b,c,d)internal.polari.multiValueContextMenuCB(...
    a,b,c,d,datasetIndex,'Marker'));
    ht(1).Parent.Enable=internal.LogicalToOnOff(~is_intensity_data);



    if make&&~masterMenu
        internal.ContextMenus.createContext({hc,'Properties...',...
        @(h,~)openPropertyEditor_Dataset(p),'separator','on'});

        internal.ContextMenus.createContext({hc,'Bring to Front',...
        @(~,~)reorderDataPlot(p,+1),'separator','on'});
        internal.ContextMenus.createContext({hc,'Send to Back',...
        @(~,~)reorderDataPlot(p,-1)});
    end

    ht=findobj(hc,'Tag','Properties...');
    if~isempty(ht)
        ht.Enable=internal.LogicalToOnOff(~is_intensity_data);
    end
    if make&&~isempty(hDummy)
        delete(hDummy);
    end

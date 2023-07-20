function peakTabularReadout(p,vis)


    if nargin<2
        vis=true;
    end


    pt=p.hPeakTabularReadout;
    if isempty(pt)||~isvalid(pt)
        pt=internal.polariPeaksTable(p);
        pt.ContextMenuFcn=@(hMenu,ev)updateContextMenu(pt,hMenu);

        p.hPeakTabularReadout=pt;

        addlistener(pt,'CloseRequest',@(h,e)deleteTable(p));
    end


    pt.Width=150;
    pt.Visible=vis;

end

function deleteTable(p)




    if isvalid(p)
        showPeaksTable(p,false);
    end

end

function updateContextMenu(pt,hMenu)





    delete(hMenu.Children);

    p=pt.PolariObj;

    ds_idx=p.pCurrentDataSetIndex;
    label=['<html><b>PEAKS</b><br>'...
    ,'<font size=3>'...
    ,'<i>',sprintf('DATASET %d',ds_idx),'</i></font></html>'];

    headerOpts={hMenu,label,'','Enable','off'};
    internal.ContextMenus.createContext(headerOpts);

    opts={hMenu,'Show Table',@(~,~)deleteTable(p),'separator','on'};
    h=internal.ContextMenus.createContext(opts);
    h.Checked='on';


    make=true;
    parentLabel='Num Peaks';
    childLabel=['<html><b>PEAKS</b><br>'...
    ,'<font size=3><i> DATASET ',sprintf('%d',ds_idx)...
    ,'</i><br></html>'];
    menuLabels={parentLabel,childLabel};
    sep=true;
    internal.ContextMenus.createContextSubmenu(p,make,sep,...
    hMenu,menuLabels,...
    p.PeaksValues,{'Peaks',ds_idx},p.PeaksValuesInt);



    internal.ContextMenus.createContext({hMenu,'Refresh Peaks',@(~,~)m_refreshPeaks(p,0)});
    internal.ContextMenus.createContext({hMenu,'Remove Peaks',@(~,~)m_removePeaks(p)});
    internal.ContextMenus.createContext({hMenu,'Export Peaks',@(~,~)m_exportPeaks(p)});

end

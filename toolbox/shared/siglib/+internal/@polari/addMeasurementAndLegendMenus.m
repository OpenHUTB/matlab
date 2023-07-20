function addMeasurementAndLegendMenus(p,hc,make,topLevel,markerParent)







    if isempty(hc)
        return
    end



    if make
        if nargin<5
            markerParent=[];
        end


        opts={hc,'Measurements',''};
        if topLevel
            opts=[opts,'separator','on'];
        end
        hp=internal.ContextMenus.createContext(opts);
        internal.ContextMenus.createContext({hp,'Dummy',''});
        hp.Callback=@(h,~)createMeasurementContextMenu(p,h,markerParent);
        hp.UserData='MeasurementParent';
        if isappdata(hc,'RFMetrics')
            setappdata(hp,'RFMetrics',true);
        end
    end



...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

    addLegendMenus(p,hc,make);



























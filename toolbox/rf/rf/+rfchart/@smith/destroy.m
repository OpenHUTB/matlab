function h=destroy(h,destroyData)







    if nargin<2||~strcmp(class(destroyData),'handle.EventData')
        h.delete;
        return

    elseif strcmp(class(destroyData.Source),'axes')
        h.delete;
        return
    end


    if ishghandle(h.StaticGrid)
        delete(h.StaticGrid);
    end
    if ishghandle(h.AdmittanceGrid)
        delete(h.AdmittanceGrid);
    end
    if ishghandle(h.ImpedanceGrid)
        delete(h.ImpedanceGrid);
    end



function changeActiveDataset(p,newDataSetIndex)





    if p.pCurrentDataSetIndex==newDataSetIndex
        return
    end


    m=p.hCursorAngleMarkers;
    if~isempty(m)
        angVec=getAngleFromVec(m);
    end


    Nsets=getNumDatasets(p);
    if newDataSetIndex>Nsets
        error('Dataset index must be a positive integer <= %d.',Nsets);
    end
    p.pCurrentDataSetIndex=newDataSetIndex;

    plot_data_active(p);



    if~isempty(m)
        updateActiveTraceMarkers(m,angVec);
    end

    updateLegendForActiveTrace(p);

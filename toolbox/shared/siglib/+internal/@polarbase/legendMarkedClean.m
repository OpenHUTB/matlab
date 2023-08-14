function legendMarkedClean(p)





    if p.pLabelsPendingUpdate
        p.pLabelsPendingUpdate=false;
        updateDataLabels(p,'update');
    end

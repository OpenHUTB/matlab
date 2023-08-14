function update=updateCache(p)






    update=p.pPublicPropertiesDirty;
    if update||~strcmpi(p.NextPlot,'replacechildren')
        updateDataLabels(p,'update');

        p.pPublicPropertiesDirty=false;
    end

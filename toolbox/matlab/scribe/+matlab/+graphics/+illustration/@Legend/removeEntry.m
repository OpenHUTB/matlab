function removeEntry(hObj,legendableObject)


    pc=hObj.PlotChildren;
    hObj.PlotChildren=pc(pc~=legendableObject);


    pcs=hObj.PlotChildrenSpecified;
    hObj.PlotChildrenSpecified=pcs(pcs~=legendableObject);


    hObj.PlotChildrenExcluded=[hObj.PlotChildrenExcluded;legendableObject];


    delete(hObj.findEntry(legendableObject));



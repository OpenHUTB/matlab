function setDataPlotZ(p,z)


    h=getDataWidgetHandles(p);
    N=getNumDatasets(p);
    for i=1:N
        setappdata(h(i),'smithiZPlane',z(i));
        h(i).ZData(:)=z(i);
    end
function props=getSetObservableProps(p)



    m=metaclass(p);
    pl=m.PropertyList;
    so=[pl.SetObservable];
    pso=pl(so);
    props={pso.Name};







    skip={'AngleDrag_Delta',...
    'ColorOrderIndex','NextPlot','View',...
    'pCurrentDataSetIndex',...
    'hAxes','hFigure',...
    'hDataLine',...
    'hPeakAngleMarkers',...
    'hCursorAngleMarkers',...
    'hAngleLimCursors'};

    for i=1:numel(skip)
        props(strcmpi(props,skip{i}))=[];
    end

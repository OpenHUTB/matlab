function showAllLocationLoggingNTScopes()






    shh='ShowHiddenHandles';
    shhState=get(0,shh);
    set(0,shh,'on');

    allLocationLoggingHistogramFigs=findobj('type','figure','-regexp','tag','^locationLogging_histogramFigure');

    for idx=1:length(allLocationLoggingHistogramFigs)
        figure(allLocationLoggingHistogramFigs(idx));
    end

    set(0,shh,shhState);

end

function closeAllLocationLoggingNumericTypeScopes(tagSuffix)





    shh='ShowHiddenHandles';
    shhState=get(0,shh);
    set(0,shh,'on');
    tag='locationLogging_histogramFigure';
    if nargin==1
        tag=[tag,'_',tagSuffix];
        allLocationLoggingHistogramFigs=findobj('type','figure','tag',tag);
    else
        allLocationLoggingHistogramFigs=findobj('type','figure','-regexp','tag',['^',tag]);
    end

    close(allLocationLoggingHistogramFigs);

    set(0,shh,shhState);

end

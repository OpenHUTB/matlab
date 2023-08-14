function layout=makeTwoSystemLayout(topId,bottomId)




    import comparisons.internal.highlight.ContentId
    import sldiff.internal.highlight.layout.getDefaultReportPosition
    import sldiff.internal.highlight.layout.getDefaultSystemPosition

    modelScreenWidthFraction=0.5;

    positions=struct(...
    topId,getDefaultSystemPosition(true,modelScreenWidthFraction),...
    bottomId,getDefaultSystemPosition(false,modelScreenWidthFraction),...
    ContentId.Report,getDefaultReportPosition(1-modelScreenWidthFraction)...
    );

    layout=comparisons.internal.highlight.FixedPositionLayout(positions);

end


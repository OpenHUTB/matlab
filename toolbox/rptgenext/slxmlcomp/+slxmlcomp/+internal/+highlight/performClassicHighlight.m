function performClassicHighlight(...
    topHighlightActionData,...
    bottomHighlightActionData,...
    layout,...
    comparisonReport)




    ensureSystemLoaded(topHighlightActionData);
    ensureSystemLoaded(bottomHighlightActionData);

    setCurrentWindowPositionsSupplier(topHighlightActionData,bottomHighlightActionData);

    slxmlcomp.internal.highlight.runJHighlightAction(...
    topHighlightActionData,...
    slxmlcomp.internal.highlight.SLEditorClassicStyler(),...
    layout,...
comparisonReport...
    );

    slxmlcomp.internal.highlight.runJHighlightAction(...
    bottomHighlightActionData,...
    slxmlcomp.internal.highlight.SLEditorClassicStyler(),...
    layout,...
comparisonReport...
    );

end

function ensureSystemLoaded(jHighlightData)
    import slxmlcomp.internal.highlight.window.BDInfo;
    bdInfo=BDInfo.fromJHighlightData(jHighlightData);

    bdInfo.ensureLoaded();
end

function setCurrentWindowPositionsSupplier(topHighlightActionData,bottomHighlightActionData)

    [leftModel,rightModel]=getModelPaths(topHighlightActionData,bottomHighlightActionData);

    import slxmlcomp.internal.highlight.window.getJavaReportPosition;

    function positions=getCurrentPositions()
        positions=struct(...
        "Left",getModelPosition(leftModel),...
        "Right",getModelPosition(rightModel),...
        "Report",getJavaReportPosition(leftModel,rightModel)...
        );
    end

    slxmlcomp.internal.highlight.CurrentWindowPositionSupplier.setInstance(@getCurrentPositions);

end

function[leftModel,rightModel]=getModelPaths(topData,bottomData)
    leftModel="";
    rightModel="";
    models=struct();
    models.(char(topData.getPositionID()))=char(topData.getFile().getAbsolutePath());
    models.(char(bottomData.getPositionID()))=char(bottomData.getFile().getAbsolutePath());

    if isfield(models,"Left")
        leftModel=models.Left;
    end
    if isfield(models,"Right")
        rightModel=models.Right;
    end
end

function position=getModelPosition(model)

    position=[];
    positionManager=slxmlcomp.internal.highlight.PositionManager.getInstance();
    if positionManager.hasHighlighter(model)
        highlighter=positionManager.getHighlighter(model);
        highlighter.pIsVisible();
        position=highlighter.LastSimulinkPosition;
    end

end

function storeWindowPositions()






    currentPositionSupplier=slxmlcomp.internal.highlight.CurrentWindowPositionSupplier.getInstance();

    if isempty(currentPositionSupplier)
        return
    end
    windowPositions=currentPositionSupplier();

    opts=slxmlcomp.options;

    if~isempty(windowPositions.Left)
        opts.PreferredSimulinkPositionLeft=windowPositions.Left;
        opts.PreferredStateflowPositionLeft=windowPositions.Left;
    end

    if~isempty(windowPositions.Right)
        opts.PreferredSimulinkPositionRight=windowPositions.Right;
        opts.PreferredStateflowPositionRight=windowPositions.Right;
    end

    if~isempty(windowPositions.Report)
        opts.PreferredReportPosition=windowPositions.Report;
    end

end

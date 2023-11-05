function comparison=compare(left,right)


    import comparisons.internal.util.APIUtils;

    files=comparisons.internal.resolveFiles(left,right);
    [viewFactory,driver]=APIUtils.getViewFactoryAndDriver(files);
    compareAndWait(driver);
    comparison=APIUtils.createMATLABView(viewFactory,driver);
end

function compareAndWait(driver)
    import comparisons.internal.util.ComparisonTask;
    try
        task=ComparisonTask(driver);
        cleanup=onCleanup(@()determineCancelled(task,driver));
        task.invokeAndWait();
    catch exception
        onFailure(driver);
        exception.rethrow();
    end
end

function determineCancelled(task,driver)
    if task.Cancelled
        onFailure(driver);
    end
end

function onFailure(driver)
    driver.dispose();
end
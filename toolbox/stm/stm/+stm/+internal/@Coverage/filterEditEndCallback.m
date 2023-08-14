



function filterEditEndCallback(resultId,filterFileNames)
    import stm.internal.Coverage;

    oc=onCleanup(@()stm.internal.Spinner.stopSpinner);

    Coverage.applyFilter(str2double(resultId),Coverage.normalizeExtensions(filterFileNames));
end

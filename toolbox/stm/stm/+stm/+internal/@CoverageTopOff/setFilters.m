


function setFilters(tfObj,cvResult)
    cs=tfObj.getCoverageSettings;
    try
        files=string(cvResult.filter);
        cs.CoverageFilterFilename=[cs.CoverageFilterFilename;files(:)];
    catch me %#ok<NASGU>

    end
end

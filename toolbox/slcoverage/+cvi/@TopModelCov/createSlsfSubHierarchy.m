function createSlsfSubHierarchy(subSysH)
    try

        modelH=bdroot(subSysH);
        oldCovPath=get_param(modelH,'CovPath');
        covPath=getfullname(subSysH);
        covPath=covPath(numel(get_param(modelH,'name'))+1:end);
        set_param(modelH,'CovPath',covPath);
        coveng=cvi.TopModelCov.getInstance(modelH);
        SlCov.CoverageAPI.compileForCoverage(modelH);
        set_param(modelH,'CovPath',oldCovPath);
    catch MEx
        rethrow(MEx);
    end

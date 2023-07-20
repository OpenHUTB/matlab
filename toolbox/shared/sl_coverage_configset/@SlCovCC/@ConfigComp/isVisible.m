function result=isVisible(h)



    try
        result=h.isDialogFeatureOn&&...
        license('test',SlCov.CoverageAPI.getLicenseName)&&...
        exist('cvsim','file');
    catch MEx %#ok<NASGU>
        result=false;
    end
function out=getDefaultBuildDir(h)




    if h.isModelReference
        out=h.getModelRefBuildDir;
    else
        out=h.getMostRecentBuildDir();
    end


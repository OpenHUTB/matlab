function out=existBuildDir




    try
        [buildDir,prjDir]=RptgenRTW.getBuildDir;
    catch
        out=false;
        return
    end

    if exist(buildDir,'dir')&&exist(prjDir,'dir')
        out=true;
    else
        out=false;
    end

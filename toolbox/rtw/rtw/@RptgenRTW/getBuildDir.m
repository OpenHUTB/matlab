function[srcDir,prjDir]=getBuildDir(currModel)




    if nargin>0
        currModel=convertStringsToChars(currModel);
    end

    if nargin==0
        adSL=rptgen_sl.appdata_sl;
        currModel=adSL.CurrentModel;
    end

    bDirInfo=RTW.getBuildDir(currModel);
    mpath=fileparts(get_param(currModel,'FileName'));

    currObj=RptgenRTW.getSourceSubsystem;
    if isempty(currObj)
        relBuildDir=bDirInfo.RelativeBuildDir;
    else
        relBuildDir=[currObj,bDirInfo.BuildDirSuffix];
    end

    if exist(fullfile(pwd,relBuildDir),'dir')
        srcDir=fullfile(pwd,relBuildDir);
    else
        srcDir=fullfile(mpath,relBuildDir);
    end


    if isempty(currObj)
        prjDir=bDirInfo.ModelRefRelativeBuildDir;
    else
        prjDir=[fileparts(bDirInfo.ModelRefRelativeBuildDir),'/'...
        ,currObj,bDirInfo.ModelRefDirSuffix];
    end
    tmwinternal='tmwinternal';
    if exist(fullfile(pwd,prjDir,tmwinternal),'dir')
        prjDir=fullfile(pwd,prjDir,tmwinternal);
    else
        prjDir=fullfile(mpath,prjDir,tmwinternal);
    end
    if~exist(srcDir,'dir')
        try
            rptInfo=rtw.report.getReportInfo(currModel);
            srcDir=rptInfo.BuildDirectory;
        catch


        end
    end
    if~exist(prjDir,'dir')||~exist(srcDir,'dir')
        prjDir=[];
        srcDir=[];
    end



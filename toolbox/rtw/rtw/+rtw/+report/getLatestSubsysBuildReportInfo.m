

function rptInfo=getLatestSubsysBuildReportInfo(model)




    rptInfo=rtw.report.ReportInfo.instance(model);
    if~isempty(rptInfo)&&isValidSubsysBuildReportInfo(model,rptInfo)
        return;
    end


    rptInfo=[];
    buildFolder=getLatestSubsysBuildFolder(model);
    if~isempty(buildFolder)
        rptInfo=rtw.report.ReportInfo.getReportInfoFromBuildDir(buildFolder);
    end


    if~isempty(rptInfo)&&~isValidSubsysBuildReportInfo(model,rptInfo)
        rptInfo=[];
    end

    function buildFolder=getLatestSubsysBuildFolder(model)
        buildFolder=[];
        dirs=RTW.getBuildDir(model);
        slprjDir=fullfile(dirs.CodeGenFolder,dirs.ModelRefRelativeBuildDir);
        mostRecentSInfo=rtw.report.ReportInfo.getSInfo(slprjDir);
        if~isempty(mostRecentSInfo)
            buildFolder=mostRecentSInfo.buildDir;
        end


        function out=isValidSubsysBuildReportInfo(model,rptInfo)
            out=false;
            if~isempty(rptInfo)&&~isempty(rptInfo.SourceSubsystem)
                [root,~]=strtok(rptInfo.SourceSubsystem,':/');
                if strcmp(root,model)
                    out=true;
                end
            end



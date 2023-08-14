function[rptInfo,ref]=getReportInfo(model,ref)


    if nargin<2
        ref=false;
    end

    if ref
        try
            rptInfo=loc_getRefBuildReportInfo(model);
        catch ME1
            try
                rptInfo=loc_getTopBuildReportInfo(model);
                ref=false;
            catch ME2
                rethrow(ME1);
            end
        end
    else
        try
            rptInfo=loc_getTopBuildReportInfo(model);
        catch ME1
            try
                rptInfo=loc_getRefBuildReportInfo(model);
                ref=true;
            catch ME2
                rethrow(ME1);
            end
        end
    end

    function rptInfo=loc_getTopBuildReportInfo(model)



        rptInfo=rtw.report.getLatestReportInfo(model);
        buildDir=rptInfo.getBuildDir;%#ok<NASGU>
        type=rptInfo.ModelReferenceTargetType;
        if strcmpi(type,'RTW')
            buildDir=rtw.report.ReportInfo.detectBuildFolder(model,'ModelReference','off');
            rptInfo=rtw.report.getReportInfo(model,buildDir);
        end

        function rptInfo=loc_getRefBuildReportInfo(model)
            buildDir=rtw.report.ReportInfo.detectBuildFolder(model,'ModelReference','on');
            rptInfo=rtw.report.getReportInfo(model,buildDir);

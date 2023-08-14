function url=getURL(obj)


    if Simulink.report.ReportInfo.featureReportV2&&~isempty(obj.CodeGenFolder)
        [~,pathName,ext]=fileparts(obj.getBuildDir);





        if~isempty(ext)
            pathName=[pathName,ext];
        end

        connector.ensureServiceOn();





        httpStr=sprintf('%s%s','report',pathName);
        alphNumReplace='MWQE';
        regStr='[^\w]';
        httpStr=regexprep(httpStr,regStr,alphNumReplace);
        httpStr=regexprep(httpStr,'_',alphNumReplace);
        urlConnector=sprintf('addons/%s/',httpStr);

        connector.addWebAddOnsPath(httpStr,fileparts(obj.getBuildDir));
        url=[connector.getBaseUrl,urlConnector,pathName,'/html/index.html'];
        url=connector.getUrl(url);
    else
        filename=obj.getReportFileFullName;
        url=loc_getFileUrl(filename);
    end
end

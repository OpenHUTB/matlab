function out=generateErrorReportPage(obj,exception)
%#ok<INUSD>
    title=DAStudio.message('RTW:report:CodeInterfaceErrorTitle',obj.ModelName);
    msg=DAStudio.message('RTW:report:CodeInterfaceInternalError');
    bodyOption=['ONLOAD="',coder.internal.coderReport('getOnloadJS','rtwIdCodeInterface'),'"'];
    out=coder.report.ReportPageBase.getDefaultErrorHTML(title,msg,bodyOption);
end

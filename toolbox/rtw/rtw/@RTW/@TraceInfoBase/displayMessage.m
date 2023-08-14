function varargout=displayMessage(h,reportPath,msgId,block)




    nargoutchk(0,1);

    if~h.DisplayErrorInBrowser
        varargout{1}='';
        return
    end
    sep='?';
    msg=strrep(msgId,'RTW:traceInfo:','rtwMsg_');

    fileURL=Simulink.document.fileURL(reportPath,[sep,'msg=',msg,'&block=',block]);
    if nargout>=1
        varargout{1}=fileURL;
        return;
    end
    fileURL=[fileURL,'&model2code_src=model'];


    if isa(h,'RTW.TraceInfo')
        rptInfo=h.getReportInfo;
    else
        rptInfo=[];
    end
    if~isempty(rptInfo)
        rptInfo.show(fileURL);
    else
        rtw.report.ReportInfo.openURL(fileURL,h.getTitle,h.HelpMethod);
    end



function dlg=setBrowserDialog(url,title,helpMethod)
    dlg=Simulink.report.ReportInfo.getBrowserDialog();
    [fileURL,searchString]=loc_getFileUrl(url);
    src='';
    if~isempty(dlg)
        src=dlg.getDialogSource;
    end
    if rtwprivate('rtwinbat')
        disp('# Code Generation Report is not launched in BaT or during test execution. The report will be launched in internal browser.');
        return
    end
    if isa(src,'Simulink.document')&&strcmp(src.documentName,url)

        if strcmp(src.SearchString,searchString)

            src.SearchString=[searchString,'&forcereload'];
        else
            src.SearchString=searchString;
        end
        dlg.refresh();
    elseif~rtw.report.ReportInfo.featureReportV2||...
        (~isempty(helpMethod)&&contains(helpMethod,'slWebView'))||...
        contains(url,'_codegen_rpt.html')

        src=Simulink.document(fileURL,title);
        src.ExplicitShow=true;
        src.Title=title;
        src.HelpMethod=helpMethod;
        src.IsCodeReportDocumentStyle=true;
        if~isempty(dlg)

            dlg.setSource(src);
        else

            dlg=Simulink.report.ReportInfo.getBrowserDialog(src);
        end
    else

        return;
    end

    waitForPageLoad(dlg,'Tag_Coder_Report_Dialog',5);

    dlg.evalBrowserJS('Tag_Coder_Report_Dialog','top.location.reload();');
end


function waitForPageLoad(dlg,tag,timeOutDuration)
    loadState="loading";
    ticStart=tic;
    while(loadState~="complete")
        loadState=dlg.evalBrowserJS(tag,'top.document.readyState');

        elapsedTime=toc(ticStart);
        if(elapsedTime>timeOutDuration)
            break;
        end
    end
end

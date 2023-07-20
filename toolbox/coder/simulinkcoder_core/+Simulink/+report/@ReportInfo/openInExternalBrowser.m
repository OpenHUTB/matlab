function openInExternalBrowser(url)
    if rtwprivate('rtwinbat')
        disp('# Code Generation Report is not launched in BaT or during test execution. The report will be launched in external browser.');
        return
    end
    try
        isOpen=~web(url,'-browser');
    catch ME %#ok
        isOpen=false;
    end
    if~isOpen
        [~,filename]=fileparts(url);
        MSLDiagnostic('RTW:report:ReportOpenFailure',sprintf('"<a href="%s">%s</a>"',url,filename)).reportAsWarning;
    end
end

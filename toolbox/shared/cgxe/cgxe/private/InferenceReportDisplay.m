function InferenceReportDisplay(fullBlkPath)




    mdlName=bdroot(fullBlkPath);
    htmlDirPath=fullfile(pwd,'slprj','_cgxe',mdlName,'info');
    mainHtmlName=fullfile(htmlDirPath,codergui.ReportServices.getReportFilename(htmlDirPath));

    if~exist(mainHtmlName,'file')
        throw(MException(message('Coder:reportGen:noReportAvailable',gcs)));
    else
        codergui.internal.showReportViewer(mainHtmlName);
    end

end
function browseOutputDir(dlgsrc,hDlg,tag)









    pathName=uigetdir(...
    dlgsrc.outputDir,...
    dlgsrc.bxlate('BaseOutputDirBrowseDialogTitle'));

    if pathName~=0
        setWidgetValue(hDlg,tag,pathName);
    end

end










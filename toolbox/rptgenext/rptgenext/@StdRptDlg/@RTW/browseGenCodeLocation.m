function browseGenCodeLocation(dlgsrc,hDlg,tag)









    pathName=uigetdir(...
    dlgsrc.codegenFolder,...
    dlgsrc.xlate('RTWGenCodeDirBrowseDialogTitle'));

    if pathName~=0
        setWidgetValue(hDlg,tag,pathName);
    end
end










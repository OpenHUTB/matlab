function browseTemplateFile(dlgsrc,hDlg,tag)









    [filename,pathname]=uigetfile({'*.dotx'},...
    dlgsrc.templateFile,...
    dlgsrc.xlate('RTWTemplateBrowseDialogTitle'));

    if pathname~=0
        setWidgetValue(hDlg,tag,fullfile(pathname,filename));
    end

end



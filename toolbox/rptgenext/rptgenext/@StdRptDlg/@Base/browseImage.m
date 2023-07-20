function browseImage(dlgsrc,hDlg,tag)



    [fileName,pathName]=uigetfile(...
    {'*.png','(*.png)';...
    '*.gif','(*.gif)';...
    '*.*',dlgsrc.bxlate('AllFiles')},...
    dlgsrc.bxlate('BaseImageBrowseDialogTitle'));

    if pathName~=0
        setWidgetValue(hDlg,tag,fullfile(pathName,fileName));
    end

end










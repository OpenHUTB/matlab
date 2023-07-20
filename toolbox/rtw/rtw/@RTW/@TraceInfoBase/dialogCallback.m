function dialogCallback(hSrc,hDlg,tag)




    switch tag
    case 'Tag_TraceInfo_BuildDirBrowse'
        tag_BuildDir='Tag_TraceInfo_BuildDir';
        currDir=getWidgetValue(hDlg,tag_BuildDir);
        if isempty(currDir)
            startDir=pwd;
        else
            if ispc
                startDir=currDir;
            else
                startDir=fileparts(currDir);
            end
        end
        newDir=uigetdir(startDir,DAStudio.message('RTW:traceInfo:browseButton'));
        if~isempty(newDir)
            setWidgetValue(hDlg,tag_BuildDir,newDir);
        end
    end
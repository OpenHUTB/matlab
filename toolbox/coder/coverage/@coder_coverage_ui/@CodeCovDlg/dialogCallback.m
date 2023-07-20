function dialogCallback(hSrc,hDlg,tag,action)




    enableApplyButton=true;

    switch tag

    case 'Tag_CodeCoverage_InstallationFolderBrowse'

        initPath=getWidgetValue(hDlg,'Tag_CodeCoverage_InstallationFolderEdit');
        initPath=strtrim(initPath);
        if~exist(initPath,'dir')
            initPath=fullfile(matlabroot,'..');
        end

        newPath=uigetdir(initPath,action);

        if~isequal(newPath,0)
            i_setNewPath(newPath,hSrc.ToolClass,hDlg);
            coverageToolObj=feval(hSrc.ToolClass);
            detectedToolVersion=coverageToolObj.getActualVersion;
            setWidgetValue(hDlg,'Tag_CodeCoverage_SelectedToolVersion',...
            detectedToolVersion);
        else
            enableApplyButton=false;
        end

    case 'Tag_CodeCoverage_InstallationFolderEdit'

        newPath=getWidgetValue(hDlg,'Tag_CodeCoverage_InstallationFolderEdit');
        newPath=strtrim(newPath);

        i_setNewPath(newPath,hSrc.ToolClass,hDlg);

    end


    if enableApplyButton
        hDlg.enableApplyButton(true,false);
    end



    function i_setNewPath(newPath,toolClass,hDlg)

        coder.coverage.setCoverageToolPath(toolClass,newPath);
        setWidgetValue(hDlg,'Tag_CodeCoverage_InstallationFolderEdit',...
        newPath);

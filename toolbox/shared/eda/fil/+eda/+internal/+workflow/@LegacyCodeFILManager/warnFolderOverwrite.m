function success=warnFolderOverwrite(h)






    success=true;

    toolName=h.mProjMgr.mToolInfo.FPGAToolName;
    [~,projPath]=h.mProjMgr.isExistingProject;
    prj=sprintf('   %s\n',projPath{:});


    ClassName=[h.mBuildInfo.DUTName,'_fil'];
    FileName=[ClassName,'.m'];
    FilePath=fullfile('.',FileName);








    if~isa(h.mBuildInfo,'eda.internal.workflow.FILBuildInfo')
        msg=sprintf(['The following folder already exists:\n%s\n',...
        'Overwrite existing folder?'],h.mBuildInfo.OutputFolder);
        warnmsg='Overwriting the following folder';
        title='Existing folder found';
    else
        if strcmp(h.mBuildInfo.Tool,'MATLAB System Object')
            msg=sprintf(['The following folder or file already exists:\n%s\n%s\n',...
            'Overwrite existing folder and file?'],h.mBuildInfo.OutputFolder,FilePath);
            warnmsg='Overwriting the following folder and file';
            title='Existing folder or file found';
        else
            msg=sprintf(['The following folder already exists:\n%s\n',...
            'Overwrite existing folder?'],h.mBuildInfo.OutputFolder);
            warnmsg='Overwriting the following folder';
            title='Existing folder found';
        end
    end
    if h.BuildOpt.NoWarn
        go=true;
    elseif h.BuildOpt.QuestDlg
        answer=questdlg(msg,title,...
        'Overwrite','Cancel','Overwrite');
        drawnow;
        go=strcmp(answer,'Overwrite');
    else


        try
            msg=strrep(sprintf('%s [y]/n ',msg),'\','\\');
            go=~strcmpi(input(msg,'s'),'n');
        catch ME %#ok<NASGU>
            go=true;
        end
    end

    if go


        if h.mProjMgr.mToolInfo.isFPGAToolRunning
            msg=sprintf(['%s is running. Make sure the following '...
            ,'project is not opened:\n%s\nNew project may not be '...
            ,'created properly otherwise.'],toolName,prj);
            if h.BuildOpt.NoWarn
                go=true;
            elseif h.BuildOpt.QuestDlg
                answer=questdlg(msg,'Project may be active',...
                'Continue','Cancel','Continue');
                drawnow;
                go=strcmp(answer,'Continue');
            else
                msg=strrep(sprintf('\n%s\nContinue? [y]/n ',msg),'\','\\');
                go=~strcmpi(input(msg,'s'),'n');
            end
        end
    end

    if go
        warning(message('EDALink:LegacyCodeFILManager:warnProjectOverwrite:OverwriteProjectFiles',warnmsg,h.mBuildInfo.OutputFolder));
        if h.mProjMgr.mToolInfo.isFPGAToolRunning
            warning(message('EDALink:LegacyCodeFILManager:warnProjectOverwrite:FPGAToolRunning',toolName));
        end
    else
        success=false;
        h.displayStatus('FIL folder not created.');
    end

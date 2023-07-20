function success=warnProjectOverwrite(h)








    success=true;
    toolName=h.mProjMgr.mToolInfo.FPGAToolName;


    [~,projPath]=h.mProjMgr.isExistingProject;
    prj=sprintf('   %s\n',projPath{:});


    if h.isExistingBitFile
        f=sprintf('   %s\n',projPath{:},h.mBuildInfo.FPGAProgrammingFile);
        msg=sprintf(['The following %s project and programming file '...
        ,'already exist:\n%s\nOverwrite existing files?'],toolName,f);
        warnmsg='Overwriting the following project and programming file';
    else
        f=prj;
        msg=sprintf(['The following %s project already exists:\n%s\n',...
        'Overwrite existing project?'],toolName,prj);
        warnmsg='Overwriting the following project';
    end

    if h.BuildOpt.NoWarn
        go=true;
    elseif h.BuildOpt.QuestDlg
        answer=questdlg(msg,'Existing project found',...
        'Overwrite','Cancel','Overwrite');
        drawnow;
        go=strcmp(answer,'Overwrite');
    else
        msg=strrep(sprintf('%s [y]/n ',msg),'\','\\');
        go=~strcmpi(input(msg,'s'),'n');
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
        warning(message('EDALink:LegacyCodeFILManager:warnProjectOverwrite:OverwriteProjectFiles',warnmsg,f));
        if h.mProjMgr.mToolInfo.isFPGAToolRunning
            warning(message('EDALink:LegacyCodeFILManager:warnProjectOverwrite:FPGAToolRunning',toolName));
        end
    else
        success=false;
        h.displayStatus('FPGA project not created.');
    end

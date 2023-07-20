function success=warnBitFileOverwrite(h)




    success=true;

    bit=sprintf('   %s\n',h.mBuildInfo.FPGAProgrammingFile);
    msg=sprintf(['The following FPGA programming file already exists:\n%s\n',...
    'Overwrite the existing file?'],bit);

    if h.BuildOpt.NoWarn
        go=true;
    elseif h.BuildOpt.QuestDlg
        answer=questdlg(msg,'Existing programming file found',...
        'Overwrite','Cancel','Overwrite');
        drawnow;
        go=strcmp(answer,'Overwrite');
    else
        msg=strrep(sprintf('%s [y]/n ',msg),'\','\\');
        go=~strcmpi(input(msg,'s'),'n');
    end

    if go
        warning(message('EDALink:LegacyCodeFILManager:warnBitFileOverwrite:OverwriteBitFile',bit));
    else
        success=false;
        h.displayStatus('FPGA project not created.');
    end


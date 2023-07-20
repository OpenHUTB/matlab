function cmdstr=checkUnixCommand(canonicalPath,cmd)















    assert(isunix);

    canonicalCmdstr=fullfile(canonicalPath,cmd);
    [status,output]=system(['which ',canonicalCmdstr]);%#ok<NASGU>
    if(status==0)
        cmdstr=canonicalCmdstr;
        return;
    end



    [status,output]=system(['which ',cmd]);
    if(status~=0)
        error(message('hwconnectinstaller:setup:UnixCommandNotFound',cmd));
    end
    cmdstr=strtrim(output);
    warning(message('hwconnectinstaller:setup:UnixCommandIsNotCanonical',cmdstr,canonicalCmdstr));

end


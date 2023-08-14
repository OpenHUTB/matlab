function resolvedName=resolveTildeChars(filename)






    if ispc
        resolvedName=filename;
        return
    end
    if isempty(filename)
        filename='';
    end
    mfile=['hwconnectinstaller.util.',mfilename];
    validateattributes(filename,{'char'},{},mfile,'filename');
    if isempty(strfind(filename,'~'))
        resolvedName=filename;
        return;
    end



    filename=strrep(filename,' ','\ ');
    resolvedName=strtrim(invokeSystemCommand(['echo ',filename]));
end




function output=invokeSystemCommand(cmd)

    [status,output]=system(cmd);
    if(status~=0)
        error(message('hwconnectinstaller:setup:UnixCommandInvocationError',cmd,output));
    else
        hwconnectinstaller.internal.inform(output);
    end

end
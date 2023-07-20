function[helpStr]=sscpFile(fullFileName)





    helpStr='';

    [pn,fn,en]=fileparts(fullFileName);

    if strcmpi(en,'.sscp')
        if exist(fullFileName,'file')
            helpStr=sscp_help_internal(fullFileName);
        end
    end

end

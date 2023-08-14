function[helpStr]=sscFile(fullFileName)





    helpStr='';

    [pn,fn,en]=fileparts(fullFileName);

    if strcmpi(en,'.ssc')
        if exist(fullFileName,'file')
            helpStr=ssc_help_internal(fullFileName);
        end
    end

end



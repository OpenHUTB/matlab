function check_headerfile_string(hdrfile)












    [id,arg]=check_headerfile_string_msg(hdrfile);
    if~isempty(arg)
        DAStudio.error(id,arg);
    elseif~isempty(id)
        DAStudio.error(id);
    end



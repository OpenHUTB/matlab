function multiThreadLogging(value)






    if strcmpi(value,'on')
        builtin('_simscape_disk_logging_multithread',true);
    else
        builtin('_simscape_disk_logging_multithread',false);
    end

end

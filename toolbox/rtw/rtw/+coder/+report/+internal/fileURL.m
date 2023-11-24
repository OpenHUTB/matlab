function out=fileURL(filepath,search)

    if filepath(1)=='/'||strncmp(filepath,'\\',2)
        prefix='file://';
    else
        prefix='file:///';
    end

    filepath=strrep(filepath,'%','%25');
    filepath=strrep(filepath,'#','%23');
    filepath=strrep(filepath,'?','%3F');
    filepath=strrep(filepath,' ','%20');

    out=strcat(prefix,filepath,search);
    out=strrep(out,'\','/');

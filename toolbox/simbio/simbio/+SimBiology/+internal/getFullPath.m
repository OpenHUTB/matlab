function[fullpath,errmsg]=getFullPath(filename)















    [fid,errmsg]=fopen(filename);
    if fid==-1
        fullpath='';
    else
        fullpath=fopen(fid);
        fclose(fid);
    end
end
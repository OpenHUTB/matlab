function file=spiceNetlist2String(fname)






    fid=fopen(fname);
    if fid==-1
        pm_error('physmod:ee:spice2ssc:CannotOpenFile',fname);
    end
    s=fgetl(fid);
    ii=1;
    file=string.empty;
    while~isnumeric(s)
        file(ii)=s;
        ii=ii+1;
        s=fgetl(fid);
    end
    fclose(fid);
function b=compareFilenames(f1,f2)










    if ispc
        b=strcmpi(f1,f2);
    else
        b=strcmp(f1,f2);
    end



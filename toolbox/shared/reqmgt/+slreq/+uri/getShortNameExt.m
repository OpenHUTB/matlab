function[out,fDir]=getShortNameExt(in)






    [fDir,fName,fExt]=fileparts(in);
    out=[fName,fExt];
end

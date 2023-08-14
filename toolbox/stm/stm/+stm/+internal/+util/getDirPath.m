function[dirpath]=getDirPath(inpath)






    pathstr=fileparts(inpath);
    fileSeparator=filesep();

    dirpath=[pathstr,fileSeparator];
end

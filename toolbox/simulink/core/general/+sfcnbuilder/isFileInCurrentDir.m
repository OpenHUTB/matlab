function out=isFileInCurrentDir(fileName)

    presentDir=pwd;
    out=0;
    fileNamefullPath=[presentDir,filesep,fileName];
    if(exist(fileNamefullPath)==2)
        out=1;
    end
end
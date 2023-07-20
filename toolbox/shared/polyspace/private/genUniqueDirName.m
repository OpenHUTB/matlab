function[dirName,existingDir]=genUniqueDirName(dirName)




    rootDir=dirName;
    existingDir='';
    index=0;

    if ispc&&startsWith(rootDir,filesep)
        rootDir=fullfile(pwd,rootDir);
    end

    while exist(rootDir,'dir')==7

        existingDir=rootDir;

        index=index+1;
        rootDir=sprintf('%s_%d',dirName,index);
    end
    dirName=rootDir;

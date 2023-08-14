function res=isInSubDirectory(path1,path2)









    path1=polyspace.internal.getAbsolutePath(path1);
    path2=polyspace.internal.getAbsolutePath(path2);


    currDir=pwd;


    FILESYSTEM_IS_IN_DIRECTORY=2;
    res=filesystem_mex(FILESYSTEM_IS_IN_DIRECTORY,currDir,path1,path2);

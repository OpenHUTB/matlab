function[genDir,genBase]=ne_gendir(sourceFile)












    DIRNAME='sscprj';
    SUFFIX='';

    [fileDir,fileBase]=fileparts(sourceFile);


    genDir=fullfile(pm_fullpath(fileDir),DIRNAME);

    genBase=[fileBase,SUFFIX];

end

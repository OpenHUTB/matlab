function metadata=deserializeMetadata(appObj,mldatxPath,filename)





    if~endsWith(mldatxPath,'/')
        mldatxPath=[mldatxPath,'/'];
    end
    appObj.extract([mldatxPath,[filename,'.json']]);
    str=fileread(fullfile(appObj.getWorkingDir,mldatxPath,[filename,'.json']));
    metadata=jsondecode(str);

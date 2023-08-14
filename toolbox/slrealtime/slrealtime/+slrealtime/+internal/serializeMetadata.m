function serializeMetadata(appObj,metadata,mldatxPath,filename)





    if~endsWith(mldatxPath,'/')
        mldatxPath=[mldatxPath,'/'];
    end
    str=jsonencode(metadata);
    f=fopen(fullfile(appObj.getWorkingDir,[filename,'.json']),'w');
    fwrite(f,str);
    fclose(f);
    appObj.add([mldatxPath,[filename,'.json']],fullfile(appObj.getWorkingDir,[filename,'.json']));

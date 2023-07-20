function b=setMetaData(rootFolder,key,value)



    b=false;



    if~isvarname(key)||isempty(value)
        return
    end



    appKey="ALM";


    proj=alm.internal.project.getProject(rootFolder);


    fmgr=matlab.internal.project.metadata.FileMetadataManager(proj,appKey);


    try
        metaData=fmgr.getMetadata(rootFolder);

        if isempty(metaData)
            metaData=matlab.internal.project.metadata.FileMetadataNode;
        end

    catch
        metaData=matlab.internal.project.metadata.FileMetadataNode;
    end


    metaData.set(key,value);
    fmgr.setMetadata(rootFolder,metaData);

    b=true;

end

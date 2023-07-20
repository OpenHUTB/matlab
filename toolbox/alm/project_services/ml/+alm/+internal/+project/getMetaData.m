function value=getMetaData(rootFolder,key)



    value='';

    if~isvarname(key)
        return;
    end



    appKey="ALM";


    proj=alm.internal.project.getProject(rootFolder);


    fmgr=matlab.internal.project.metadata.FileMetadataManager(proj,appKey);



    try
        metaData=fmgr.getMetadata(proj.RootFolder);
        if~isempty(metaData)
            value=char(metaData.get(key));
        end
    catch ME

    end

end

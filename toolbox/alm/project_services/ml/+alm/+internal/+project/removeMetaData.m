function b=removeMetaData(rootFolder,key)




    b=false;

    if~isvarname(key)
        return;
    end



    appKey="ALM";


    proj=alm.internal.project.getProject(rootFolder);


    fmgr=matlab.internal.project.metadata.FileMetadataManager(proj,appKey);



    try
        metaData=fmgr.getMetadata(rootFolder);
    catch
        metaData=[];
    end

    if~isempty(metaData)
        metaDataNew=matlab.internal.project.metadata.FileMetadataNode;
        keys=metaData.getKeys();
        for i=1:numel(keys)
            if keys(i)~=key
                metaDataNew.set(keys(i),metaData.get(keys(i)));
            else
                b=true;
            end
        end
        if numel(metaData.getKeys())>0
            fmgr.setMetadata(rootFolder,metaDataNew);
        else
            fmgr.removeEntry(rootFolder);
        end
    else
        fmgr.removeEntry(rootFolder);
    end

end

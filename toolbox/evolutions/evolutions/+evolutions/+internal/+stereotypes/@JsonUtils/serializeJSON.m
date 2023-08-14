function serializeJSON(info,jsonData)




    evolutions.internal.utils.createDirSafe(info.ArtifactRootFolder);

    fid=fopen(info.PropertyDataFile,'w');
    fwrite(fid,jsonData);
    fclose(fid);

end

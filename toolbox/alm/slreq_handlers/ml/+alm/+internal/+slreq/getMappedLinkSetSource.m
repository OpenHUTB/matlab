function srcFile=getMappedLinkSetSource(fullPathToLinkFile)








    status=true;

    mapper=rmimap.StorageMapper.getInstance();


    srcFile=mapper.getSourceFor(fullPathToLinkFile);

    if isempty(srcFile)
        srcFile='';
    else
        srcFile=srcFile{1};
    end
end

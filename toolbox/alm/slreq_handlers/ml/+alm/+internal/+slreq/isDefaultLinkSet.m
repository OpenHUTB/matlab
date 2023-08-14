function status=isDefaultLinkSet(fullPathToLinkFile)








    status=true;

    mapper=rmimap.StorageMapper.getInstance();
    srcFile=mapper.getSourceFor(fullPathToLinkFile);

    status=isempty(srcFile);
end

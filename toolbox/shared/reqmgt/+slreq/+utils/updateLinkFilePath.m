function updateLinkFilePath(srcPath,newLinkFilePath)

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(srcPath);
    if isempty(linkSet)
        return;
    end

    if nargin<2||isempty(newLinkFilePath)
        newLinkFilePath=rmimap.StorageMapper.getInstance.getStorageFor(srcPath);
    end

    linkSet.updateLinksFileLocation(newLinkFilePath);

end


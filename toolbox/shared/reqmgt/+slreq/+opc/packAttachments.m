function packAttachments(package,reqSet,newFilePath)



    lastSavedPath=reqSet.getLastSavedFilePath();




    if~strcmp(lastSavedPath,newFilePath)
        attachmentMgr=slreq.attach.AttachmentManager(lastSavedPath);
        if attachmentMgr.needsCopying(newFilePath)
            attachmentMgr.copyAttachments(newFilePath);
        end
    end

end
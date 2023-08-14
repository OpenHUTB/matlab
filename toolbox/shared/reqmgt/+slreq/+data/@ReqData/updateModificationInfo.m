function updateModificationInfo(mfobject)






    if ispc
        currentUser=getenv('USERNAME');
    else
        currentUser=getenv('USER');
    end
    mfobject.modifiedBy=currentUser;


    mfobject.modifiedOn=datetime('now','TimeZone','UTC');
    if mfobject.revision==0&&~isa(mfobject,'slreq.datamodel.ExternalRequirement')
        mfobject.createdBy=currentUser;


    end
end

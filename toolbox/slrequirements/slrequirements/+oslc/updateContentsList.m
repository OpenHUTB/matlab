function updateContentsList(projName,collectionId)






    proj=oslc.Project.registry(projName);
    proj.updateContentsList(collectionId);

end

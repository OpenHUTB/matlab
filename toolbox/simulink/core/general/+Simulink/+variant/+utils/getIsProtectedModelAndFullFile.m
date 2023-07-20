function[isProtected,fullFileName]=getIsProtectedModelAndFullFile(modelName)











    [isProtected,fullFileName]=slInternal('getReferencedModelFileInformation',modelName);
end
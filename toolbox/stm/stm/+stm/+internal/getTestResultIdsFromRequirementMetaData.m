function resultIds=getTestResultIdsFromRequirementMetaData(testIdOrTestName,testFileName)




    [~,~,fileExt]=fileparts(testFileName);
    if strcmp(fileExt,'.m')
        resultIds=sltest.internal.getTestResultIdsFromTestNameAndTestFile(testIdOrTestName,testFileName);
    else
        resultIds=stm.internal.getTestResultIdFromUUIDAndTestFileName(testIdOrTestName,testFileName);
    end
end

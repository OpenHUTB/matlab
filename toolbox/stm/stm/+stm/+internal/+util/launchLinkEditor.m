function launchLinkEditor(testFile,testId,testName)




    [~,~,fExt]=fileparts(testFile);
    if strcmpi(fExt,'.m')
        rmitm.editLinks(testFile,testName);
    else
        rmitm.editLinks(testFile,testId);
    end
end

function[testFilePath,testIdentifier,descriptionString]=getCurrentTestCase()












    testFilePath='';
    testIdentifier='';
    descriptionString='';
    testID=stm.internal.getSelectedTestCaseId();
    if(testID>0)
        test=sltest.testmanager.Test.getTestObjFromID(testID);
        if isempty(test)


            return;
        elseif isa(test,'sltest.testmanager.TestFile')
            testFilePath=test.FilePath;
        else
            testFilePath=test.TestFile.FilePath;
        end

        isMATLABUnitTest=endsWith(testFilePath,'.m','IgnoreCase',true);
        if isMATLABUnitTest

            testIdentifier=regexprep(test.Name,'\([^\)]+)$','');
        else
            testIdentifier=test.UUID;
        end

        descriptionString=test.Name;

        if~isempty(testFilePath)&&~isempty(descriptionString)
            descriptionString=getString(message('stm:general:DescriptionForTestCase',...
            descriptionString,testFilePath));
        end
    end
end


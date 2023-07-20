

function tagArray=getAllTestTags
    testFiles=sltest.testmanager.getTestFiles;
    tagArray=[string.empty,testFiles.Tags];

    for testFile=testFiles
        testSuites=testFile.getAllTestSuites;
        tagArray=[tagArray,[testSuites.Tags]];%#ok<AGROW> 

        testCases=testFile.getAllTestCases;
        tagArray=[tagArray,[testCases.Tags]];%#ok<AGROW> 
    end

    tagArray=sort(unique(tagArray));
end

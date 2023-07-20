function isOnCurrentRelease=isRunningOnCurrentReleaseOnly(sltest_testcase)
    isOnCurrentRelease=true;
    if~isempty(sltest_testcase.Releases)
        currRlsName=string(message('stm:MultipleReleaseTesting:CurrentRelease'));


        if strcmp(sltest_testcase.TestType,'equivalence')
            isOnCurrentRelease=isequal(sltest_testcase.Releases(1),currRlsName)&&...
            isequal(sltest_testcase.Releases(2),currRlsName);
        else
            isOnCurrentRelease=isequal(sltest_testcase.Releases,currRlsName);
        end
    end
end
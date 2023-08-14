function[suites,items,index]=getTestItems(filepath)


    tFile=sltest.testmanager.load(filepath);
    obj=stm.internal.getTestProperty(tFile.getID(),'testsuite');
    items(1)=TestItem(obj.uuid,tFile.Name,'','',tFile.Requirements);
    index(1)=0;
    suites={};


    tSuites=tFile.getTestSuites();
    for i=1:numel(tSuites)
        oneSuite=tSuites(i);
        obj=stm.internal.getTestProperty(oneSuite.getID(),'testsuite');
        items(end+1)=TestItem(obj.uuid,tFile.Name,oneSuite.Name,'',oneSuite.Requirements);%#ok<AGROW>
        index(end+1)=i;%#ok<AGROW>
        suites{end+1}=oneSuite.Name;%#ok<AGROW>
        tCases=oneSuite.getTestCases();
        for j=1:numel(tCases)
            oneTest=tCases(j);
            obj=stm.internal.getTestProperty(oneTest.getID(),'testcase');
            items(end+1)=TestItem(obj.uuid,tFile.Name,oneSuite.Name,oneTest.Name,oneTest.Requirements);%#ok<AGROW>
            index(end+1)=i;%#ok<AGROW>
        end
    end

end

function testItem=TestItem(uuid,testFile,testSuit,testCase,reqs)
    testItem.uuid=uuid;
    testItem.file=testFile;
    testItem.suite=testSuit;
    testItem.case=testCase;
    testItem.reqs=reqs;
end

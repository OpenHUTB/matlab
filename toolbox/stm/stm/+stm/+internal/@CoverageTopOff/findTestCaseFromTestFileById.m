

function tcObj=findTestCaseFromTestFileById(tfObj,tcId)


    tsObjList=tfObj.getTestSuites();
    while(~isempty(tsObjList))
        tmpTCList=tsObjList(1).getTestCases();
        for k=1:length(tmpTCList)
            if(tmpTCList(k).getID()==tcId)
                tcObj=tmpTCList(k);
                return;
            end
        end

        tmpTSList=tsObjList(1).getTestSuites();
        tsObjList=[tsObjList(2:end),tmpTSList'];
    end
    tcObj=sltest.testmanager.TestCase.empty;
end


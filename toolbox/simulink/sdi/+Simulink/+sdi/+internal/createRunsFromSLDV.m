function runIDs=createRunsFromSLDV(sldvData)






    eng=Simulink.sdi.Instance.engine();
    runIDs=eng.safeTransaction(@helperCreateRunsFromSLDV,sldvData);
end

function runIDs=helperCreateRunsFromSLDV(sldvData)
    tstCnt=numel(sldvData.TestCases);
    runIDs=zeros(tstCnt,1);
    for idx=1:tstCnt
        try
            slInData=eval('sldvsimdata(sldvData, idx)');
        catch me
            throwAsCaller(me);
        end
        runIDs(idx)=Simulink.sdi.createRun(...
        slInData.Name,'vars',slInData);
    end
end
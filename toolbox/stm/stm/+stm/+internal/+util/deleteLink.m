function deleteLink(testFile,testId,idx,testName)




    [~,~,fExt]=fileparts(testFile);
    if strcmpi(fExt,'.m')
        testId=testName;
    end
    try
        reqs=rmitm.getReqs(testFile,testId);

        if max(idx)>length(reqs)

            return;
        end


        reqs(idx)=[];
        rmitm.setReqs(testFile,testId,reqs);
    catch
        error(message('stm:general:SLReqNotInstalled'));
    end
end

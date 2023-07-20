function req=selectionLink(reqsys,testFile,testId,testName)




    if rmi.isInstalled()
        [~,~,fExt]=fileparts(testFile);
        if strcmp(fExt,'.m')
            req=rmitm.selectionLink(reqsys,testFile,testName);
        else
            req=rmitm.selectionLink(reqsys,testFile,testId);
        end
    else
        error(message('stm:general:SLReqNotInstalled'));
    end
end

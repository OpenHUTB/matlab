function callCustomPostProcessingHook(obj)








    assert(~isempty(obj.relationshipClasses));


    fileList={};
    for i=1:length(obj.relationshipClasses)
        currentRelationship=obj.relationshipClasses{i};
        fileList=[fileList,currentRelationship.getFileList()];%#ok<AGROW>
    end
    fileList=unique(fileList);


    srcFileList={};
    otherFileList={};
    for i=1:length(fileList)
        currentFile=fileList{i};
        [~,~,ext]=fileparts(currentFile);
        if strcmp(ext,'.c')||strcmp(ext,'.h')||strcmp(ext,'.hpp')||strcmp(ext,'.cpp')
            srcFileList=[srcFileList,currentFile];%#ok<AGROW>
        else
            otherFileList=[otherFileList,currentFile];%#ok<AGROW>
        end
    end


    try
        cachedPwd=pwd;
        restorePwd=onCleanup(@()cd(cachedPwd));
        if strcmp(obj.CodeInterface,'Top model')
            mdlRefTgtType='NONE';
        else
            mdlRefTgtType='RTW';
        end
        hookInfo=Simulink.ModelReference.ProtectedModel.HookInfo(srcFileList,otherFileList,obj.ModelName,mdlRefTgtType);

        feval(obj.CustomHookCommand,hookInfo);
    catch exc

        warnState=warning('query','backtrace');
        oc=onCleanup(@()warning(warnState));
        warning off backtrace;

        errMsg=rtwprivate('escapeOriginalMessage',exc);
        errID='RTW:buildProcess:invalidPostCodeGenCommand';
        errMsg=DAStudio.message(errID,'CustomPostProcessingHook',obj.ModelName,errMsg);
        newExc=MException(errID,errMsg);
        newExc=newExc.addCause(exc);
        throw(newExc);
    end
end
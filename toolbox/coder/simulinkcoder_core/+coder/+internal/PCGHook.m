function PCGHook(modelName_in,buildInfo_in,lXilInfo)









    pcgCommand=get_param(modelName_in,'PostCodeGenCommand');


    coderTargetCmd='codertarget.postCodeGenHookCommand(h)';
    if contains(pcgCommand,coderTargetCmd)
        pcgCommand=strrep(pcgCommand,coderTargetCmd,'');


        coderTargetBuildArgs=struct...
        (...
        'XilInfo',{lXilInfo});
        coderTargetHookData=struct...
        ('MdlRefBuildArgs',{coderTargetBuildArgs},...
        'BuildInfo',{buildInfo_in},...
        'ModelName',{modelName_in});


        codertarget.postCodeGenHookCommand(coderTargetHookData);
    end


    if~isempty(pcgCommand)
        i_runPcgCommand(pcgCommand,modelName_in,buildInfo_in)
    end


    function i_runPcgCommand(pcgCommand,modelName,buildInfo)%#ok<INUSD>



        if strcmp(get_param(modelName,'RTWVerbose'),'on')
            disp('### Evaluating PostCodeGenCommand specified in the model');
        end
        try


            cur_pwd=pwd;

            eval(pcgCommand);
        catch exc



            errMsg=rtwprivate('escapeOriginalMessage',exc);
            cd(cur_pwd);
            errID='RTW:buildProcess:invalidPostCodeGenCommand';
            errMsg=DAStudio.message(errID,'PostCodeGenCommand',modelName,errMsg);
            newExc=MException(errID,errMsg);
            newExc=newExc.addCause(exc);
            throw(newExc);
        end


        if~strcmp(cur_pwd,pwd)
            MSLDiagnostic('RTW:makertw:changeDirNotAllowed',...
            'PostCodeGen command',pwd,cur_pwd).reportAsWarning;
            cd(cur_pwd);
        end

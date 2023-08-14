function result=upgradeAdvisorCheckCB(system)







    model=bdroot(system);
    maObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    maObj.setCheckErrorSeverity(1);

    result={};
    passOrFail=true;


    stfResult=checkSTF(model);
    result{end+1}=stfResult;

    if strcmpi(stfResult.SubResultStatus,'Warn')


        passOrFail=true;
    else


        result{end+1}=checkBlocks(model);


        result{end+1}=checkSignals(model);


        result{end+1}=checkConfigParams(model);

        result{end}.setSubBar(0);

        for i=1:length(result)
            if~strcmpi(result{i}.SubResultStatus,'Pass')
                passOrFail=false;
            end
        end
    end

    maObj.setCheckResultStatus(passOrFail);
    maObj.setActionEnable(~passOrFail);




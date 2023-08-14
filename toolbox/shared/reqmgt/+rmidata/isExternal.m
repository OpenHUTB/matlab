function[result,modelH]=isExternal(model)






    model=convertStringsToChars(model);

    if ischar(model)
        modelH=get_param(model,'Handle');
    else
        modelH=model;
        model=get_param(modelH,'Name');
    end


    if isempty(modelH)||modelH==0
        warning(message('Slvnv:reqmgt:isExternal',model));
        result=false;
        return;
    end


    if rmiut.isBuiltinNoRmi(modelH)
        result=false;
        return;
    end

    if rmisl.isComponentHarness(modelH)

        systemModel=Simulink.harness.internal.getHarnessOwnerBD(modelH);
        result=rmidata.isExternal(systemModel);
        return;
    end


    result=rmidata.storageModeCache('get',modelH);
end


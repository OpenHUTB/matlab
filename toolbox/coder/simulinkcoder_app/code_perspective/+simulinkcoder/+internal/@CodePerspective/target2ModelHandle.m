function modelH=target2ModelHandle(~,target)





    modelH=get_param(bdroot(target),'Handle');
    if strcmp(get_param(modelH,'IsHarness'),'on')
        modelH=get_param(Simulink.harness.internal.getHarnessOwnerBD(modelH),'Handle');
    end



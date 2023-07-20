function actionSignal=findActionSignalInNtwk(~,mergeInput)








    [actionSignal,nicArray]=hdldefaults.Merge.findSignalThroughHierarchy(mergeInput,@hdldefaults.Merge.actionSignalPred);
    if isempty(actionSignal)


        return;
    end



    actionSignalInNtwk=@(signal)hdldefaults.Merge.signalInNtwkPred(signal,mergeInput.Owner);
    actionSignal=hdldefaults.Merge.findSignalThroughHierarchy(actionSignal,actionSignalInNtwk,nicArray);
end



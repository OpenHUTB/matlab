function onMATLABExit()




    targets=slrealtime.Targets;
    names=targets.getTargetNames();
    for i=1:length(names)
        tg=targets.getTarget(names{i});
        tg.disconnect();
    end

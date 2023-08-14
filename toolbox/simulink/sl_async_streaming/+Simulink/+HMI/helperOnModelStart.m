function helperOnModelStart(mdl,eng,repo,opts)











    if~isfield(opts,'TargetComputer')
        opts.TargetComputer='';
    end


    Simulink.sdi.WebClient.setActiveStreamingModel(...
    mdl,...
    opts.StartTime,...
    opts.TargetComputer);


    if Simulink.sdi.Instance.isRepositoryCreated()
        qs=Simulink.AsyncQueue.Queue.getAllQueues(mdl,false,opts.TargetComputer);
        if isfield(opts,'VisualizeOn')&&opts.VisualizeOn&&~isempty(qs)
            eng.dirty=true;
        end
        Simulink.sdi.modelStartCallback(mdl,opts.RecordOn,opts.VisualizeOn,opts.CommandLine,opts.TargetComputer);

        args={};
        if isfield(opts,'StopTime')
            args={mdl,opts.StartTime,opts.StopTime};
        end
        Simulink.sdi.internal.pushRunMetaDataFromWorker(args{:});
    end


    Simulink.HMI.SignalInterface.startStreamingToWeb(repo,mdl,opts);
end

function LoadDataAndLaunchSDI(fname)

    initRunCount=length(Simulink.sdi.getAllRunIDs());
    if Simulink.sdi.isSessionFile(fname)
        if initRunCount>0&&Simulink.sdi.Instance.isSDIRunning
            Simulink.sdi.internal.controllers.SessionSaveLoad.loadSDISession(...
            fname,'appName','sdi');
        else
            Simulink.sdi.load(fname);
        end
    else
        Simulink.sdi.loadView(fname);
    end

    Simulink.sdi.view();
end
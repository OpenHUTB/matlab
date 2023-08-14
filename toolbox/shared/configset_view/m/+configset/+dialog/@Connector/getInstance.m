function obj=getInstance()




    mlock;
    persistent ins;

    if isempty(ins)
        if~connector.isRunning
            load_simulink;
            connector.ensureServiceOn;
        end

        ins=configset.dialog.Connector();
    end

    obj=ins;
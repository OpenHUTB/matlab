function result = debugLoop(this, obj)
    % Call keyboard and wait for debugging to finish

    % Copyright 2019 The MathWorks, Inc.
    currSimStatus = get_param(this.ModelName, 'SimulationStatus');
    % skip loop if mock debug mode -- this is to avoid the keyboard call
    while currSimStatus == "paused" && ~stm.internal.isDebugMode(true)
        currSimStatus = get_param(this.ModelName, 'SimulationStatus');
        % free UI thread to make Simulink Toolstrip responsive
        if this.pause
            sltest.testmanager.keyboard;
        end

        % stop the test if needed
        if stm.internal.readStopTest == 1
            set_param(this.ModelName, 'SimulationCommand', 'stop');
            evt = event.EventData;
            notify(obj.modelUtil, 'ModelStopped', evt);
        end
    end

    result = evalin('base', get_param(this.ModelName, 'ReturnWorkspaceOutputsName'));
end

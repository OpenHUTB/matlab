function isPaused = pause(obj)
    simStatus = get_param(obj.ModelName, 'SimulationStatus');
    isPaused = strcmpi('paused',simStatus);
    % if simulation is still paused but user hit continue or dbcont
    if (isPaused)
        callback = @(varargin)cb_Stop(obj);
        if isempty(obj.StopTimer)
            obj.StopTimer = timer('Name', sltest.testmanager.Debugger.TimerName);
            obj.StopTimer.TimerFcn = callback;
            obj.StopTimer.ObjectVisibility = 'off';
            obj.StopTimer.Period = 0.5;
            obj.StopTimer.ExecutionMode = 'fixedRate';
            start(obj.StopTimer);
        end
        
        % print the message only once
        if ~obj.IsPaused
            obj.IsPaused = true;
            home;
            assignin('base',obj.VarName,obj.Msg);
            % we need to do this in base workspace so that when the
            % debugger pauses, user is in the base workspace
            evalin('base', ['fprintf(' obj.VarName ');clear(''' obj.VarName ''');']);
        end
    end
end

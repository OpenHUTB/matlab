function cb_Stop(obj)
    % stop the test if needed

    % Copyright 2016-2020 The MathWorks, Inc.
    if (stm.internal.readStopTest() == 1)
        stm.internal.dbcont;
        stop(obj.StopTimer);
        delete(obj.StopTimer);
        obj.StopTimer = [];
    end

    if ~isempty(obj.StopTimer)
        simStatus = get_param(bdroot, 'SimulationStatus');
        isStopped = strcmpi('stopped',simStatus);
        % for fast restart
        isCompiled = strcmpi('compiled',simStatus);

        if (isStopped || isCompiled)
            stop(obj.StopTimer);
            delete(obj.StopTimer);
            obj.StopTimer = [];
            % simply calling dbcont here will error out because we are
            % not in the same execution context. Hence, we
            % asynchronously call dbcont using MVM.
            % Also, calling stm.internal.dbcont will error out if
            % execution was halted by dbquit. So, we need to check if
            % the tests have completely stopped. If yes, then no need
            % to call dbcont.
            if (stm.internal.getTestRunningFlag ~= 0)
                stm.internal.dbcont;
            end
        end
    end
end

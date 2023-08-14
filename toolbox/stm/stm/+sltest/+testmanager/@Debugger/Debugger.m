classdef Debugger < handle
    % Class to help debugging from Test Manager

    % Copyright 2016-2019 The MathWorks, Inc.
    properties (SetAccess = immutable)
        ModelName char;
        VarName char;
        Msg char;
    end

    properties (SetAccess = private)
        StopTimer = []; % timer object to handle model/test stopping
        ModelState Simulink.internal.TemporaryModelState;
        WorkspaceRestore stm.internal.util.RestoreVariable;
        StepperCleanup onCleanup;
        DirtyCleanup onCleanup;
        MainModelDirtyCleanup onCleanup;
        LockCleanup onCleanup;
    end

    properties (Access = private)
        IsPaused (1,1) logical = false;
    end

    properties (Constant)
        TimerName = 'sltestmgrdebug';
    end

    methods
        result = debugLoop(this, obj);

        function obj = Debugger(modelName)
            obj.ModelName = modelName;
            
            % construct message to be displayed at command prompt
            obj.Msg = message('stm:general:DebugMessage', obj.ModelName).getString;
            [~,obj.VarName,~] = fileparts(tempname);
        end

        function delete(obj)
            timers = timerfindall('Name', sltest.testmanager.Debugger.TimerName);
            if ~isempty(timers)
                delete(timers);
                obj.StopTimer = [];
            end
        end
    end

    methods (Static)
        sldbg = enterDebug(runTestCfg, tcID);

        function bool = supportsDebug(simMode)
            % debug mode is supported only for these sim modes
            bool = simMode == "normal" || simMode == "accelerator";
        end
    end
end

classdef WorkspaceListener < handle
    % This class is unsupported and might change or be removed without
    % notice in a future version.

    % A class defining MATLAB Workspace Listener.  Extend this class to listen
    % to Workspace events, and implement the workspaceUpdated method.  This will
    % be called when there are changes to the workspace.

    % Copyright 2019-2021 The MathWorks, Inc.
    properties (Dependent = true)
        WorkspaceListenerEnabled;
    end

    properties (Access = {?WorkspaceListener, ?matlab.unittest.TestCase }, Transient, NonCopyable, Hidden)
        WorkspaceListenerEnabledI
    end

    methods
        function this = WorkspaceListener(createListener)
            arguments
                createListener (1,1) logical = true;
            end
            % Create a WorkspaceListener.  The listeners are created once, and
            % kept persistent.  Any new instances of a WorkspaceListener will be
            % added to the WorkspaceListeners list, but no new MVM events are
            % added.
            internal.matlab.datatoolsservices.WorkspaceListener.setupListeners();
            if createListener
               this.addListeners();
            end
        end

        function delete(this)
            % Delete the WorkspaceListener by removing it from the list of
            % WorkspaceListeners.  The MVM events are not deleted.
            lst = internal.matlab.datatoolsservices.WorkspaceListener.getWorkspaceListenersList;
            lst.removeListener(this);
        end

        % Listeners are added instantly as soon as requested.
        function addListeners(this)
             this.WorkspaceListenerEnabled = true;
        end

        % Listeners are removed lazily. They are marked WorkspaceListenerEnabled:false
        % and removed in the next workspaceUpdated cycle.
        function removeListeners(this)
            % Remove the WorkspaceListener by removing it from the list of
            % WorkspaceListeners.  The MVM events are not deleted.
            this.WorkspaceListenerEnabled = false;
        end

        function val = get.WorkspaceListenerEnabled(obj)
            val = obj.WorkspaceListenerEnabledI;
        end

        function set.WorkspaceListenerEnabled(obj, val)
            obj.WorkspaceListenerEnabledI = val;
            if val
                % If listener does not already exist, add to the current
                % list.
                lst = obj.getWorkspaceListenersList();
                if isempty(lst.findListener(obj))
                    lst.addListener(obj);
                end
            end
        end
    end

    methods(Access = private, Static = true)
        function [changeCurrWSListener, wsChangedListener, wsClearedListener, varChangeListener, varDeleteListener] = setupListeners()
            % Setup the Listeners, keeping them persistent.
            persistent ChangeCurrentWorkspaceEventListener;
            persistent WorkspaceChangedEventListener;
            persistent WorkspaceClearedEventListener;
            persistent VariablesChangedEventListener;
            persistent VariablesDeletedEventListener;

            if isempty(ChangeCurrentWorkspaceEventListener)
                % This event is generated when the user uses dbup/dbdown when
                % stopped in a debug workspace.  There are no variable names
                % associated with this event.
                ChangeCurrentWorkspaceEventListener = matlab.internal.mvm.eventmgr.MVMEvent.subscribe(...
                    '::MathWorks::ExecutionEvents::ChangeCurrentWorkspaceEvent', ...
                    @(evt) internal.matlab.datatoolsservices.WorkspaceListener.workspaceUpdatedCorrectContext(evt, false, ...
                    internal.matlab.datatoolsservices.WorkspaceEventType.CHANGE_CURR_WORKSPACE));
            end

            if isempty(WorkspaceChangedEventListener)
                % This event is generated when a breakpoint is hit.  There are
                % no variable names associated with this event.
                WorkspaceChangedEventListener = matlab.internal.mvm.eventmgr.MVMEvent.subscribe(...
                    '::MathWorks::ExecutionEvents::WorkspaceChangedEvent', ...
                    @(evt) internal.matlab.datatoolsservices.WorkspaceListener.workspaceUpdatedCorrectContext(evt, false, ...
                    internal.matlab.datatoolsservices.WorkspaceEventType.WORKSPACE_CHANGED));
            end

            if isempty(WorkspaceClearedEventListener)
                % This event is generated when the user does a clear all.  There
                % are no variable names associated with this event.
                WorkspaceClearedEventListener = matlab.internal.mvm.eventmgr.MVMEvent.subscribe(...
                    '::MathWorks::ExecutionEvents::WorkspaceClearedEvent', ...
                    @(evt) internal.matlab.datatoolsservices.WorkspaceListener.workspaceUpdatedCorrectContext(evt, false, ...
                    internal.matlab.datatoolsservices.WorkspaceEventType.WORKSPACE_CLEARED));
            end

            if isempty(VariablesChangedEventListener)
                % This event is generated when the user changes variables in
                % their workspace, either when variables are created or their
                % value changes.  The variable names are passed with the event
                % data.
                VariablesChangedEventListener = matlab.internal.mvm.eventmgr.MVMEvent.subscribe(...
                    '::MathWorks::ExecutionEvents::VariablesChangedEvent', ...
                    @(evt) internal.matlab.datatoolsservices.WorkspaceListener.workspaceUpdatedCorrectContext(evt, true, ...
                    internal.matlab.datatoolsservices.WorkspaceEventType.VARIABLE_CHANGED));
            end

            if isempty(VariablesDeletedEventListener)
                % This event is generated when variables are deleted.  The
                % variable names are passed with the event data.
                VariablesDeletedEventListener = matlab.internal.mvm.eventmgr.MVMEvent.subscribe(...
                    '::MathWorks::ExecutionEvents::VariablesDeletedEvent', ...
                    @(evt) internal.matlab.datatoolsservices.WorkspaceListener.workspaceUpdatedCorrectContext(evt, true, ...
                    internal.matlab.datatoolsservices.WorkspaceEventType.VARIABLE_DELETED));
            end

            changeCurrWSListener = ChangeCurrentWorkspaceEventListener;
            wsChangedListener = WorkspaceChangedEventListener;
            wsClearedListener = WorkspaceClearedEventListener;
            varChangeListener = VariablesChangedEventListener;
            varDeleteListener = VariablesDeletedEventListener;
        end

        function logEvent(str, varargin)
            arguments
                str string
            end

            arguments(Repeating)
                varargin
            end

            if internal.matlab.datatoolsservices.WorkspaceListener.logEventsEnabled
                if ~endsWith(str, newline)
                    str = str + newline;
                end
                str = sprintf("%s: %s", string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), str);
                fprintf(str, varargin{:});
            end
        end
    end

    methods(Abstract = true)
        % Called when workspace updates occur
        workspaceUpdated(this, varNames, eventType);
    end

    methods(Static = true)
        function workspaceUpdatedCorrectContext(aEvent, expectVarNames, eventType)
            % Called by the event listener.  Corrects the context by executing
            % in the user's workspace, using the builtin _dtcallback function.
            doUpdate = true;
            varNames = {};
            isAnsOnlyVariableChange = false;
            allVarsExisting = true;

            if ~expectVarNames
                varList = [];
            elseif isempty(aEvent) || ~isprop(aEvent, 'Details') || ~isfield(aEvent.Details, 'varnames')
                varList = '';
            else
                varNames = aEvent.Details.varnames.item;
                if ~iscellstr(varNames) %#ok<ISCLSTR>
                    varNames = {varNames};
                end

                if ~isempty(varNames)
                    varList = join(varNames, ''',''');
                else
                    varList = '';
                end

                % Gather some details about the event, whether it is a variables
                % changed event or not, if there was only a single variable
                % which changed, and if 'ans' was the only variable which
                % changed
                varChangeEvent =  isfield(aEvent.Details, 'VariablesChangedEvent');
                singleVarChange = varChangeEvent && length(varNames) == 1;
                isAnsOnlyVariableChange = singleVarChange && strcmp(varNames{1}, 'ans');

                internal.matlab.datatoolsservices.WorkspaceListener.logEvent(...
                    "varChangeEvent: %d, singleVarChange: %d, isAnsOnlyVariableChange: %d", varChangeEvent, singleVarChange, isAnsOnlyVariableChange);

                if varChangeEvent
                    % Check to see if the variables which were notified as
                    % changed actually exist in the workspace.  There are cases
                    % where they may not exist yet.
                    varsInWS = evalin('debug', 'who');
                    allVarsExisting = all(cellfun(@(varName) ismember(varName, varsInWS), varNames));
                    if isAnsOnlyVariableChange
                        % If ans variable is not present in workspace, do not queue this event.
                       if ~any(strcmp(varsInWS, 'ans'))
                           internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Not queuing ans Variable Changed, no ans variable");
                           return;
                       end
                    end
                end
                internal.matlab.datatoolsservices.WorkspaceListener.logEvent("allVarsExisting: %d", allVarsExisting);

                % Throttle amount the updates ignore anything < throttleTime
                currTime = posixtime(datetime('now'));
                lastUpdateTime = internal.matlab.datatoolsservices.WorkspaceListener.getSetLastUpdateTime();
                eventQueuingEnabled = internal.matlab.datatoolsservices.WorkspaceListener.eventQueueEnabled;
                timeDiff = currTime - lastUpdateTime;
                if ~isAnsOnlyVariableChange
                    tt = internal.matlab.datatoolsservices.WorkspaceListener.eventThrottleTime;
                else
                    tt = internal.matlab.datatoolsservices.WorkspaceListener.ansThrottleTime;
                end
                if ~(~eventQueuingEnabled || timeDiff >= tt || timeDiff < 0)
                    doUpdate = false;
                end
                % If the time difference between updates just for ans
                % has been more than throttleTime, do the update.  Also, if
                % the time difference is less than 0 (which can happen
                % in MOL when the location of the MATLAB session is
                % different from previous logins), also do the update to
                % get times sync'ed up for this session.
                internal.matlab.datatoolsservices.WorkspaceListener.getSetLastUpdateTime(currTime);
            end

            internal.matlab.datatoolsservices.WorkspaceListener.logEvent("doUpdate: %d", doUpdate);

            if doUpdate
                % Check to see if this event was related to the workspace
                % changing when debugging (dbstep/dbcont) or navigating the
                % stack when stopped at a breakpoint (dbup/dbdown)
                wsChange = any(eventType == [...
                    internal.matlab.datatoolsservices.WorkspaceEventType.WORKSPACE_CHANGED, ...
                    internal.matlab.datatoolsservices.WorkspaceEventType.CHANGE_CURR_WORKSPACE]);

                if wsChange || isAnsOnlyVariableChange || ~allVarsExisting
                    % If this is an event related to the workspace changing, or
                    % is an 'ans' change only, or the variables reported as
                    % changed don't exist in the workspace yet, then call the
                    % listeners when MATLAB is idle, to assure that the stack is
                    % correct, and to make sure 'ans' and other variables are
                    % available for use
                    internal.matlab.datatoolsservices.WorkspaceListener.executeAtIdle(varList, eventType);
                else
                    % Dispatch Event directly
                    internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Dispatching event(%s) for variables: %s\n", string(eventType), string(varList));
                    internal.matlab.datatoolsservices.WorkspaceListener.executeWorkspaceListeners(varList, eventType);
                end
            else
                % Coalesce and Queue event
                % Always queue ans VariablesChanged events to avoid 2 events
                % being fired.  This will mean all ans updates are delayed
                % by throttleTime but that should be sufficient to avoid two
                % events firing.
                if isAnsOnlyVariableChange
                    % Ignore ans updates as they will cause an infinite
                    % loop.  Calling the callbacks triggers workspace
                    % updates around ans.  This happens if we execute
                    % either when MATLAB IDLE or via the event queue timer.
                    internal.matlab.datatoolsservices.WorkspaceListener.logEvent('Not queuing new ans VariablesChanged event\n');
                else
                    internal.matlab.datatoolsservices.WorkspaceListener.queueEvent(varNames, eventType);
                end
            end
        end

        function t = getSetLastUpdateTime(varargin)
            % Gets or sets the last updated time
            persistent updateTime;

            if isempty(updateTime)
                updateTime = posixtime(datetime('now'));
            end

            if nargin == 1
                updateTime = varargin{1};
            end

            t = updateTime;
        end

        function disbleLXEListeners()
            % Legacy backward compatability for those calling the typo
            % version
            % TODO: Remove this by end of 21b
            internal.matlab.datatoolsservices.WorkspaceListener.disableLXEListeners;
        end

        function currentState = disableLXEListeners()
            % Disable the Workspace Listeners
            internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Disabling LXE Listeners\n");
            [A, B, C, D, E] = internal.matlab.datatoolsservices.WorkspaceListener.setupListeners();
            currentState = A.Enabled;
            A.Enabled = false;
            B.Enabled = false;
            C.Enabled = false;
            D.Enabled = false;
            E.Enabled = false;
        end

        function enableLXEListeners(state)
            arguments
                state (1,1) logical = true
            end
            % Enable the Workspace Listeners
            [A, B, C, D, E] = internal.matlab.datatoolsservices.WorkspaceListener.setupListeners();
            if state
                internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Enabling LXE Listeners\n");
            else
                internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Resetting LXE Listener state to disabled\n");
            end
            A.Enabled = state;
            B.Enabled = state;
            C.Enabled = state;
            D.Enabled = state;
            E.Enabled = state;
        end

        function t = getSetVariablesChanged(varargin)
            % Accumulates unique variable names in a persistent list.  Returns a
            % 0x0 string array when empty.  The list can be reset by passing in
            % -reset, which returns the current content and sets it to empty.
            mlock;
            persistent allVariables;

            if isempty(allVariables)
                allVariables = strings(0);
            end

            t = missing;
            if nargin == 1
                if strcmp(varargin{1}, "-reset")
                    % Reset the variables list
                    t = allVariables;
                    allVariables = strings(0);
                else
                    % Combine the variables list, keeping it unique
                    allVariables = unique([allVariables varargin{:}], "stable");
                    internal.matlab.datatoolsservices.WorkspaceListener.logEvent(...
                        "getSetVariablesChanged... allVariables = %s", strjoin(allVariables, ","));
                end
            end

            if ismissing(t)
                t = allVariables;
            end
        end

        function executeAtIdle(varList, eventType)
            % Called to execute an event when MATLAB is idle, rather than
            % executing directly in the debug workspace.  This is needed in some
            % cases where the variable may not exist in the workspace yet, or
            % when workspaces change when debugging.
            arguments
                varList string
                eventType internal.matlab.datatoolsservices.WorkspaceEventType
            end
            
            mlock;
            persistent waitingForIdle;
            if isempty(waitingForIdle)
                waitingForIdle = false;
            end

            internal.matlab.datatoolsservices.WorkspaceListener.logEvent("executeAtIdle...")
            
            % Update the list of variables being changed
            internal.matlab.datatoolsservices.WorkspaceListener.getSetVariablesChanged(varList);
            
            if ~waitingForIdle
                % If we're not waiting for idle, execute the command to wait for
                % MATLAB idle
                waitingForIdle = true;
                internal.matlab.datatoolsservices.WorkspaceListener.logEvent(...
                    "executeAtIdle... waitingForIdle = false")
                cmd = sprintf('internal.matlab.datatoolsservices.WorkspaceListener.executeWorkspaceListeners(%s, ''%s'');', ...
                    'internal.matlab.datatoolsservices.WorkspaceListener.getSetVariablesChanged("-reset")', eventType);
                foo = @(es,ed)evalin('caller', cmd);
                builtin('_dtcallback', foo, internal.matlab.datatoolsservices.getSetCmdExecutionTypeIdle);
                waitingForIdle = false;
            else
                internal.matlab.datatoolsservices.WorkspaceListener.logEvent(...
                    "executeAtIdle... waitingForIdle = true")
            end
        end

        function executeWorkspaceListeners(varNames, eventType)
            lst = internal.matlab.datatoolsservices.WorkspaceListener.getWorkspaceListenersList;
            if lst.getListenerListSize == 0
                % If there are currently no listeners, just return.  There's
                % nothing to update.
                return;
            end

            % Executes the workspace listeners in the user's workspace
            if nargin < 1 || isempty(varNames)
                varList = '';
            else
                try
                    varList = join(varNames, ''',''');
                catch
                    varList = '';
                end
            end

            currentState = internal.matlab.datatoolsservices.WorkspaceListener.disableLXEListeners;
            c = onCleanup(@()internal.matlab.datatoolsservices.WorkspaceListener.enableLXEListeners(currentState));
            try
                listenerList = lst.ListenerList;
                disabledListeners = {};
                for i=1:length(listenerList)
                    wsListener = listenerList{i};
                    if isvalid(wsListener) && wsListener.WorkspaceListenerEnabled
                        try
                            internal.matlab.datatoolsservices.WorkspaceListener.logEvent('Executing Callback on class %s with event %s on variables %s\n', class(wsListener), char(eventType), string(varList));
                            cmd = sprintf(...
                                'workspaceUpdated(internal.matlab.datatoolsservices.WorkspaceListener.getWorkspaceListenersList.getListener(%d), {''%s''}, ''%s'');', ...
                                i, string(varList), eventType);
                            evalin('debug', cmd);
                            internal.matlab.datatoolsservices.WorkspaceListener.logEvent('Callback completed on class %s with event %s on variables %s\n', class(wsListener), char(eventType), string(varList));
                        catch e
                            internal.matlab.datatoolsservices.WorkspaceListener.logEvent('\tException when calling callback: %s\n', e.message);
                        end
                    else
                        % If a listener is not Enabled or invalid, add to
                        % disabledListeners list
                        disabledListeners{end+1} = wsListener;
                    end
                end
                % Remove all disabled listeners from the current WorkspaceListenerList. 
                if ~isempty(disabledListeners)
                    for i=1:length(disabledListeners)
                       lst.removeListener(disabledListeners{i});
                       internal.matlab.datatoolsservices.WorkspaceListener.logEvent(sprintf('Removing listener class: %s',class(disabledListeners{i})));
                    end
                end
            catch err
                disp(err);
            end
        end

        function lst = getWorkspaceListenersList()
            mlock;

            persistent workspaceListeners;

            if isempty(workspaceListeners)
                workspaceListeners = internal.matlab.datatoolsservices.WorkspaceListenerList;
            end

            lst = workspaceListeners;
        end

        function queue = getEventQueue()
            mlock;

            persistent workspaceEventQueue;

            if isempty(workspaceEventQueue)
                workspaceEventQueue = containers.Map;
            end

            queue = workspaceEventQueue;
        end

        function t = getEventQueueTimer(ft)
            arguments
                ft = [];
            end

            mlock;

            persistent flushTimer;

            if ~isempty(ft)
                flushTimer = ft;
            end

            t = flushTimer;
        end

        function queueEvent(varNames, eventType)
            flushTimer = internal.matlab.datatoolsservices.WorkspaceListener.getEventQueueTimer; %#ok<*NASGU>

            internal.matlab.datatoolsservices.WorkspaceListener.deleteEventQueueTimer;

            if isempty(eventType) || isempty(varNames)
                return;
            end

            % Create timer to flush queue
            flushTimer = timer();
            flushTimer.StartDelay = internal.matlab.datatoolsservices.WorkspaceListener.eventThrottleTime;
            flushTimer.TimerFcn = @(~,~)internal.matlab.datatoolsservices.WorkspaceListener.flushEventQueue();
            internal.matlab.datatoolsservices.WorkspaceListener.getEventQueueTimer(flushTimer);

            eventQueue = internal.matlab.datatoolsservices.WorkspaceListener.getEventQueue;
            eventStr = string(eventType);

            if isKey(eventQueue, eventStr)
                s = eventQueue(eventStr);
                s.Variables = unique([s.Variables varNames]);
            else
                s = struct;
                s.Variables = varNames;
                s.EventType = eventType;
            end

            eventQueue(eventStr) = s;
            internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Queuing events(%s) for variable: %s\n", eventStr, strjoin(varNames, ","));

            flushTimer.start;
        end

        function deleteEventQueueTimer()
            try
                flushTimer = internal.matlab.datatoolsservices.WorkspaceListener.getEventQueueTimer;

                if ~isempty(flushTimer) && isvalid(flushTimer)
                    stop(flushTimer);
                    delete(flushTimer);
                end

                internal.matlab.datatoolsservices.WorkspaceListener.getEventQueueTimer([]);
            catch e
                internal.matlab.datatoolsservices.WorkspaceListener.logEvent("\tError deleting timer [%s]\n", e.message);
            end
        end

        function flushEventQueue()
            internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Flushing event queue\n");

            internal.matlab.datatoolsservices.WorkspaceListener.deleteEventQueueTimer;

            eventQueue = internal.matlab.datatoolsservices.WorkspaceListener.getEventQueue;
            k = keys(eventQueue);
            for i=1:length(k)
                s = eventQueue(k{i});
                varList = strjoin(s.Variables, ",");
                internal.matlab.datatoolsservices.WorkspaceListener.logEvent("Flushing event(%s) for variable: %s\n", string(s.EventType), varList);
                internal.matlab.datatoolsservices.WorkspaceListener.executeWorkspaceListeners(varList, s.EventType);
            end

            remove(eventQueue, k);
        end

        function enabled = logEventsEnabled(e)
            arguments
                e = [];
            end
            mlock;
            persistent isLoggingEnabled;
            if isempty(isLoggingEnabled)
                isLoggingEnabled = false;
            end

            if ~isempty(e)
                isLoggingEnabled = e;
            end

            enabled = isLoggingEnabled;
        end

        function enabled = eventQueueEnabled(e)
            arguments
                e = [];
            end
            mlock;
            persistent isQueuingEnabled;
            if isempty(isQueuingEnabled)
                isQueuingEnabled = true;
            end

            if ~isempty(e)
                isQueuingEnabled = e;
            end

            enabled = isQueuingEnabled;
        end

        function throttleTime = eventThrottleTime(tt)
            arguments
                tt = [];
            end
            mlock;
            persistent savedThrottleTime;
            if isempty(savedThrottleTime)
                savedThrottleTime = 0.1;
            end

            if ~isempty(tt)
                savedThrottleTime = tt;
            end

            throttleTime = savedThrottleTime;
        end

        function throttleTime = ansThrottleTime(tt)
            arguments
                tt = [];
            end
            mlock;
            persistent savedThrottleTime;
            if isempty(savedThrottleTime)
                savedThrottleTime = 1.0;
            end

            if ~isempty(tt)
                savedThrottleTime = tt;
            end

            throttleTime = savedThrottleTime;
        end
    end
end


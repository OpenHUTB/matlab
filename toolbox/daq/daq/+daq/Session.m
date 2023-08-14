classdef Session < daq.ISession
    %SESSION will be removed in a future release. Use
    %daq.interfaces.DataAcquisition instead (use daqhelp to learn more
    %about DataAcquisition).
    %
    %Session A session with hardware in the Data Acquisition Toolbox
    %    Represents the basic configuration and setup of an operation.  This
    %    class is not instantiated directly, but subclasses of it are
    %    defined by each vendor, with their hardware specific
    %    implementations.  Call daq.createSession(<vendor>) to instantiate.
    %
    %    Example:
    %      s = daq.createSession('ni');                      % Create session
    %      s.addAnalogInputChannel('cDAQ1Mod1',0,'Voltage'); % Add an analog input
    %      data = s.startForeground();                       % Acquire data
    %      plot(data)                                        % plot the data
    %
    % See also: daq.createSession, daq.getDevices, daq.getVendors
    
    % Copyright 2010-2022 The MathWorks, Inc.
    
    %Disable warnings about accessing properties from a property set
    %function -- this class cannot be saved.
    %#ok<*MCSUP>
    
    %% -- Public methods, properties, and events --
    % Read/write properties
    properties (SetObservable)
        %The number of scans for the operation
        NumberOfScans
        
        %The duration of the operation in seconds
        DurationInSeconds
        
        %The rate of the operation, in scans per second
        Rate
        
        %Set true to configure for continuous operation
        IsContinuous
        
        %An integer indicating the "high water mark" which will cause the
        %DataAvailable event to fire when the engine has more scans than
        %that value.  Setting this forces IsNotifyWhenDataAvailableExceedsAuto to false.
        NotifyWhenDataAvailableExceeds
        
        %When true, the NotifyWhenDataAvailableExceeds property is set
        %automatically.  Automatically changes to false when
        %NotifyWhenDataAvailableExceeds is set.
        IsNotifyWhenDataAvailableExceedsAuto
        
        %An integer indicating the "low water mark" which will cause the
        %DataRequired event to fire when the ScansQueued property drops
        %below that value.
        NotifyWhenScansQueuedBelow
        
        %When true, the NotifyWhenScansQueuedBelow property is set
        %automatically.  Automatically changes to false when
        %NotifyWhenScansQueuedBelow is set.
        IsNotifyWhenScansQueuedBelowAuto
        
        %An positive non-zero double indicating the timeout while waiting for an External
        %start trigger. This can be inf in case of startBackground.
        ExternalTriggerTimeout
        
        %An positive non-zero double representing the number of times to
        %execute the start operation. This can be inf in case of startBackground.
        TriggersPerRun
                
        %A property for storing custom information.
        UserData
    end
    
    methods
        function [el] = addlistener(varargin)
            if nargin < 3
                 varargin{1}.localizedError('daq:Session:notEnoughArgForAddlistener')
            end

            if nargin == 3 
                if strcmp(varargin{2}, 'DataAvailable')
                % Intercept calls to addlistener.  If we see the user
                % attach a listener to DataAvailable, set this flag, which
                % is checked by startBackground on analog input
                % acquisitions.
                    varargin{1}.DataAvailableListenerAdded = true;
                end
                
                if daq.internal.isScalarStringOrCharVector(varargin{2})
                    varargin{2} = char(varargin{2});
                end                
            end
            [el] = addlistener@handle(varargin{:});
        end
    end
    
    % Property access methods
    methods
        function set.Rate(obj,newValue)
            
            if obj.RateChangeInProgress == true
                obj.Rate = double(newValue);
                return;
            end
            
            try
                obj.RateChangeInProgress = true;
                % G710295: Rate will be zero when On-demand channels are
                % added to the session. Rate can only be set to zero if
                % RateLimitInfo.Max == 0
                if newValue == 0
                    if ~isempty(obj.RateLimitInfo) && obj.RateLimitInfo.Max == 0
                        obj.Rate = 0;
                        obj.RateChangeInProgress = false;
                        return;
                    end
                end
                
                % Check that parameter changes are OK in current state
                obj.InternalState.errorIfParameterChangeNotOK()
                
                % Check that newValue is a scalar numeric >= 0
                if isempty(newValue) || ~isscalar(newValue) ||...
                        ~daq.internal.isNumericNum(newValue) || newValue < 0
                    obj.localizedError('daq:Session:invalidRate');
                end
                
                if ~isempty(obj.RateLimitInfo)
                    % Check newValue against RateLimit
                    if newValue < obj.RateLimitInfo.Min
                        obj.localizedError('daq:Session:rateBelowMin',...
                            num2str(obj.RateLimitInfo.Min))
                    end
                    if newValue > obj.RateLimitInfo.Max
                        if obj.RateLimitInfo.Max ~= 0
                            obj.localizedError('daq:Session:rateAboveMax',...
                                               num2str(obj.RateLimitInfo.Max));
                        else
                            obj.localizedError('daq:Session:onDemandOnlyCannotSetRate');
                        end                        
                    end
                end

                % Retain the initial requested value so we can evaluate how
                % much it changed
                %g938466: Make certain that we pass in the correct type to
                %Rate parameter.
                newValue = double(newValue);
                originalRequestedValue = newValue;
                
                obj.Rate = originalRequestedValue;
                % Give the specialization a chance to change the value
                newValue = obj.adjustNewRateHook();
                obj.clearSingleScanCache();
                
                if ~isempty(obj.RateLimitInfo)
                    % Check newValue against RateLimit
                    % If the value is now outside the limits, reduce it to the
                    % limits
                    newValue = max(newValue,obj.RateLimitInfo.Min);
                    newValue = min(newValue,obj.RateLimitInfo.Max);
                end
                
                if ~obj.IsContinuous
                    % Unless we're in continuous mode, update the duration or
                    % number of scans, if appropriate.
                    try
                        % Suppress updates when Rate is changed
                        obj.RateDurationNumScanChangeInProgress = true;
                        if obj.IsDurationPreferred
                            % Duration is preferred, adjust number of scans
                            numberOfScans = uint64(obj.DurationInSeconds * newValue);
                            if numberOfScans < obj.MinimumNumberOfScans
                                % If this change would drive the number of scans
                                % below 2, then recalculate based on minimum value
                                % and warn. Do not warn when we add a only
                                % on-demand channel, as we throw another
                                % warning message for that particular
                                % scenario.
                                numberOfScans = obj.MinimumNumberOfScans;
                                newDuration = double(numberOfScans) / newValue;
                                if newValue ~= 0
                                    obj.fireDurationIncreasedWarning(newDuration);
                                end
                                obj.DurationInSeconds = newDuration;
                            end
                            obj.NumberOfScans = numberOfScans;
                        else
                            % NumberOfScans is preferred, adjust duration
                            obj.DurationInSeconds = double(obj.NumberOfScans) / newValue;
                        end
                        obj.RateDurationNumScanChangeInProgress = false;
                    catch e
                        obj.RateDurationNumScanChangeInProgress = false;
                        obj.RateChangeInProgress = false;
                        rethrow(e)
                    end
                end
                
                % If the new value is more than 1% different from the requested
                % value, then fire a warning.  This warning is not fired during
                % initialization
                if ~obj.isCurrentState('Initializing')
                    if abs(originalRequestedValue - newValue)...
                            /originalRequestedValue * 100 > obj.WarnOnRateVariancePercentage
                        obj.localizedWarning('daq:Session:closestRateChosen',...
                            num2str(originalRequestedValue),...
                            num2str(newValue))
                    end
                end
                obj.sessionPropertyBeingChangedHook('Rate',newValue)
                obj.Rate = newValue;
                
                obj.resetCountersImpl();
                obj.RateChangeInProgress = false;
                
                % Recalculate water marks
                obj.updateNotifyWhenDataAvailableExceedsIfNeeded();
                obj.updateNotifyWhenScansQueuedBelowIfNeeded();
            catch e
                obj.RateChangeInProgress = false;
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function set.RateLimitInfo(obj,newValue)
            % RateLimit can be set by the vendor implementations, not by
            % end users
            if ~isa(newValue,'daq.internal.ParameterLimit')
                obj.localizedError('daq:Session:invalidRateLimit')
            end
            
            % Check that parameter changes are OK in current state
            obj.InternalState.errorIfParameterChangeNotOK()
            
            % Keep RateLimit and RateLimitInfo in sync
            obj.sessionPropertyBeingChangedHook('RateLimitInfo',newValue)
            obj.RateLimitInfo = newValue;
            obj.RateLimit = double(newValue);
            
            if isempty(newValue)
                % Empty is a valid setting for RateLimitInfo.  No further
                % checks needed.
                return
            end
            
            if ~isempty(obj.Rate)
                if obj.Rate < newValue.Min
                    obj.Rate = newValue.Min;
                    obj.localizedWarning('daq:Session:rateIncreasedToMinimum',num2str(obj.Rate));
                end
                if obj.Rate > newValue.Max && newValue.Max > 0
                    obj.Rate = newValue.Max;
                    obj.localizedWarning('daq:Session:rateReducedToMaximum',num2str(obj.Rate));
                end
                % Change rate for on-demand operations without throwing a
                % warning.
                if newValue.Max == 0
                    obj.Rate = newValue.Max;
                end
            end
        end
        
        function set.DurationInSeconds(obj,newValue)
            try
                if obj.InitializationInProgress || obj.RateDurationNumScanChangeInProgress
                    % This is a side effect of another param changing -- just
                    % do it
                    obj.DurationInSeconds = double(newValue);
                    return
                end
                
                % Check that parameter changes are OK in current state
                obj.InternalState.errorIfParameterChangeNotOK()
                
                % You cannot set the Duration when in continuous mode
                if obj.IsContinuous
                    obj.localizedError('daq:Session:durationLockedOnContinuous');
                end
                
                % Check if there are output channels in the session.  If there
                % are, then error
                if obj.Channels.countOutputChannels() > 0
                    obj.localizedError('daq:Session:durationLockedOnOutput');
                end
                
                if isinf(newValue)
                    obj.localizedError('daq:Session:noInfDuration')
                end
                
                if isempty(newValue) || ~isscalar(newValue) ||...
                        ~daq.internal.isNumericNum(newValue) || newValue < 0
                    obj.localizedError('daq:Session:invalidDuration');
                end
                
                % g938466: Make certain that the new value is a double
                % We have already passed all of our input data-type
                % checking
                newValue = double(newValue);
                
                obj.RateDurationNumScanChangeInProgress = true;
                try
                    obj.IsDurationPreferred = true;
                    % Calculate the Number of scans corresponding to the
                    % duration
                    numberOfScans = uint64(floor(newValue * obj.Rate));
                    
                    if numberOfScans < obj.MinimumNumberOfScans
                        % If this change would drive the number of scans
                        % below 2, then recalculate based on minimum value
                        % and warn
                        numberOfScans = obj.MinimumNumberOfScans;
                        newValue = double(numberOfScans) / obj.Rate;
                        obj.fireDurationIncreasedWarning(newValue);
                    end
                    
                    % We only tell the vendor about updates to the number
                    % of scans -- not the Duration.
                    obj.sessionPropertyBeingChangedHook('NumberOfScans',numberOfScans)
                    obj.NumberOfScans = numberOfScans;
                    obj.RateDurationNumScanChangeInProgress = false;
                catch e
                    obj.RateDurationNumScanChangeInProgress = false;
                    rethrow(e)
                end
                % Note that we intentionally DO NOT call
                % sessionPropertyBeingChangedHook because we called it for
                % the NumberOfScans update.
                obj.DurationInSeconds = newValue;
                obj.resetCountersImpl();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function set.NumberOfScans(obj,newValue)
            try
                if obj.InitializationInProgress || obj.RateDurationNumScanChangeInProgress
                    % This is a side effect of another param changing -- just
                    % do it
                    obj.NumberOfScans = newValue; % Do not cast to uint64 here -- A valid value is Inf, which is a double
                    obj.updateNotifyWhenDataAvailableExceedsIfNeeded();
                    return
                end
                
                % No changing this value when we're in continuous mode
                if obj.IsContinuous
                    obj.localizedError('daq:Session:numScansLockedOnContinuous');
                end
                
                if ~obj.ScanQueuingInProgress
                    % These tests are disabled if we're updating NumberOfScans
                    % as a result of a queueOutputScans change
                    obj.InternalState.errorIfParameterChangeNotOK()
                    
                    % Check if there are output channels in the session.  If there
                    % are, then error
                    if obj.Channels.countOutputChannels() > 0
                        obj.localizedError('daq:Session:numScansLockedOnOutput');
                    end
                    
                    if newValue == 1
                        obj.localizedError('daq:Session:invalidNumScansOne');
                    end
                    
                    if isinf(newValue)
                        obj.localizedError('daq:Session:noInfNumScans')
                    end
                    
                    if isempty(newValue) || ~isscalar(newValue) ||...
                            ~daq.internal.isNumericNum(newValue)
                        obj.localizedError('daq:Session:invalidNumScans');
                    end
                    
                    if newValue < obj.MinimumNumberOfScans
                        obj.localizedError('daq:Session:invalidNumScansLessThanTwo');
                    end
                    
                    if newValue ~= floor(newValue)
                        obj.localizedError('daq:Session:invalidNumScansInt');
                    end
                end
                
                obj.RateDurationNumScanChangeInProgress = true;
                try
                    obj.IsDurationPreferred = false;
                    % Update the duration to match NumberOfScans
                    obj.DurationInSeconds = double(newValue) / obj.Rate;
                    obj.RateDurationNumScanChangeInProgress = false;
                catch e
                    obj.RateDurationNumScanChangeInProgress = false;
                    rethrow(e)
                end
                newValue = uint64(newValue);
                obj.sessionPropertyBeingChangedHook('NumberOfScans',newValue)
                obj.NumberOfScans = newValue;
                obj.resetCountersImpl();
                
                % Update water marks
                obj.updateNotifyWhenDataAvailableExceedsIfNeeded();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function set.TriggersPerRun(obj, newValue)
            try
                if obj.InitializationInProgress
                    % Initialization -- just do it
                    obj.TriggersPerRun = newValue;
                    return
                end
                
                obj.InternalState.errorIfParameterChangeNotOK()
                
                if isempty(newValue) || ~isscalar(newValue) ||...
                        (newValue <= 0) || (~daq.internal.isNumericNum(newValue) && ~isinf(newValue)) ||...
                        floor(newValue) ~= newValue
                    % g883748: This value must be a positive non-zero
                    % integer or inf
                    obj.localizedError('daq:Session:invalidTriggersPerRun');
                end
                
                obj.sessionPropertyBeingChangedHook('TriggersPerRun',newValue);
                obj.TriggersRemaining = newValue;
                obj.TriggersPerRun = newValue;
                
            catch e
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
        end
        
        function set.ExternalTriggerTimeout(obj, newValue)
            try
                if obj.InitializationInProgress
                    % Initialization -- just do it
                    obj.ExternalTriggerTimeout = newValue;
                    return
                end
                
                obj.InternalState.errorIfParameterChangeNotOK()
                
                if isempty(newValue) || ~isscalar(newValue) ||...
                        (newValue <= 0)
                    % This value must be a a positive non-zero. It can be
                    % inf
                    obj.localizedError('daq:Session:invalidExternalTriggerTimeout');
                end
                
                obj.sessionPropertyBeingChangedHook('ExternalTriggerTimeout',newValue);
                obj.ExternalTriggerTimeout = newValue;
                
            catch e
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
        end
        
        function set.IsContinuous(obj,newValue)
            try
                if obj.InitializationInProgress
                    % Initialization -- just do it
                    obj.IsContinuous = newValue;
                    return
                end
                
                obj.errorIfParameterChangeNotOK()
                
                if isempty(newValue) || ~isscalar(newValue) ||...
                        ~(daq.internal.isNumericNum(newValue) || islogical(newValue))
                    obj.localizedError('daq:Session:isContinuousMustBeLogical');
                end
                
                if logical(newValue) == obj.IsContinuous
                    % if the value isn't being changed, then abort
                    return
                end
                
                obj.sessionPropertyBeingChanged('IsContinuous',newValue)
                if logical(newValue)
                    % Continuous mode on.  Cache the number of scans and duration, Set the
                    % Duration and NumberOfScans to Inf.
                    try                        
                        obj.NumberOfScansCache = obj.NumberOfScans;
                        obj.DurationInSecondsCache = obj.DurationInSeconds;
                        obj.RateDurationNumScanChangeInProgress = true;
                        obj.NumberOfScans = Inf;
                        obj.DurationInSeconds = Inf;
                        obj.RateDurationNumScanChangeInProgress = false;
                        obj.IsContinuous = true;
                    catch e
                        obj.RateDurationNumScanChangeInProgress = false;
                        rethrow(e)
                    end
                else
                    % Continuous mode off.  Cache the duration preference,
                    % return the NumberOfScans and Duration to their normal
                    % values
                    try
                        obj.IsContinuous = false;
                        if obj.Channels.countOutputChannels() > 0
                            % If there are output channels, force NumberOfScans
                            % to match ScansQueued
                            obj.ScanQueuingInProgress = true;
                            obj.NumberOfScans = obj.ScansQueued;
                            obj.ScanQueuingInProgress = false;
                        else
                            % If there are no output channels, return to the
                            % old duration preference
                            if obj.IsDurationPreferred
                                obj.DurationInSeconds = obj.DurationInSecondsCache;
                            else
                                obj.NumberOfScans = obj.NumberOfScansCache;
                            end
                        end
                    catch e
                        % If there's an error, revert to the original settings
                        obj.IsContinuous = true;
                        rethrow(e)
                    end
                end
                obj.resetCountersImpl();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function set.NotifyWhenDataAvailableExceeds(obj, newValue)
            try
                if obj.InitializationInProgress || obj.WaterMarkChangeInProgress
                    % This is a side effect of another param changing -- just
                    % do it
                    obj.NotifyWhenDataAvailableExceeds = uint64(newValue);
                    return
                end
                
                obj.InternalState.errorIfParameterChangeNotOK()
                
                % G657230 When output channels are present but no data is
                % queued the property cannot be set since there is no way
                % to ensure it is being set to a valid value.
                if obj.NumberOfScans == 0
                    obj.localizedError('daq:Session:cannotSetNotifyWhenDataAvailableExceeds');
                end
                
                if isempty(newValue) || ~isscalar(newValue) || ~daq.internal.isNumericNum(newValue) ||...
                        newValue <= 0 || abs(newValue - floor(newValue)) > 0.001
                    % This value must be a scalar integer > 0 and less than
                    % NumberOfScans
                    obj.localizedError('daq:Session:invalidNotifyWhenDataAvailableExceeds');
                end
                
                if newValue > obj.NumberOfScans
                    % This value must be less than the number of scans
                    obj.localizedError('daq:Session:invalidNotifyWhenDataAvailableExceedsTooHigh');
                end
                
                if newValue < obj.Rate / obj.WarnIfEventsPerSecondExceeds
                    % If the requested NotifyWhenDataAvailableExceeds would result
                    % in notifications more often than 20 times/second, warn
                    obj.localizedWarning('daq:Session:tooFrequent');
                end
                
                % Turn off automatic tracking of Rate/NumberOfScans
                obj.IsNotifyWhenDataAvailableExceedsAuto = false;
                
                obj.NotifyWhenDataAvailableExceeds = uint64(newValue);
                obj.resetCountersImpl();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function set.IsNotifyWhenDataAvailableExceedsAuto(obj, newValue)
            try
                if obj.InitializationInProgress
                    % Initialization -- just do it
                    obj.IsNotifyWhenDataAvailableExceedsAuto = newValue;
                    return
                end
                
                obj.InternalState.errorIfParameterChangeNotOK()
                
                if isempty(newValue) || ~isscalar(newValue) ||...
                        ~(islogical(newValue) || daq.internal.isNumericNum(newValue))
                    % This value must be a scalar numeric or logical
                    obj.localizedError('daq:Session:invalidWaterMarkFlag');
                end
                
                obj.IsNotifyWhenDataAvailableExceedsAuto = logical(newValue);
                obj.WaterMarkChangeInProgress = true;
                obj.updateNotifyWhenDataAvailableExceedsIfNeeded();
                obj.WaterMarkChangeInProgress = false;
                obj.resetCountersImpl();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function set.NotifyWhenScansQueuedBelow(obj, newValue)
            try
                if obj.InitializationInProgress || obj.WaterMarkChangeInProgress
                    % This is a side effect of another param changing -- just
                    % do it
                    obj.NotifyWhenScansQueuedBelow = uint64(newValue);
                    return
                end
                
                obj.InternalState.errorIfParameterChangeNotOK()
                
                if isempty(newValue) || ~isscalar(newValue) || ~daq.internal.isNumericNum(newValue) ||...
                        newValue <= 0 || abs(newValue - floor(newValue)) > 0.001
                    % This value must be a scalar integer > 0
                    obj.localizedError('daq:Session:invalidNotifyWhenScansQueuedBelow');
                end
                
                if newValue < obj.Rate / obj.WarnIfEventsPerSecondExceeds
                    % If the requested NotifyWhenScansQueuedBelow would result
                    % in notifications more often than 20 times/seconds, warn
                    obj.localizedWarning('daq:Session:tooFrequent');
                end
                
                % Turn off automatic tracking of Rate
                obj.IsNotifyWhenScansQueuedBelowAuto = false;
                
                obj.NotifyWhenScansQueuedBelow = uint64(newValue);
                obj.resetCountersImpl();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function set.IsNotifyWhenScansQueuedBelowAuto(obj, newValue)
            try
                if obj.InitializationInProgress
                    % Initialization -- just do it
                    obj.IsNotifyWhenScansQueuedBelowAuto = newValue;
                    return
                end
                
                obj.InternalState.errorIfParameterChangeNotOK()
                
                if isempty(newValue) || ~isscalar(newValue) ||...
                        ~(islogical(newValue) || daq.internal.isNumericNum(newValue))
                    % This value must be a scalar numeric or logical
                    obj.localizedError('daq:Session:invalidWaterMarkFlag');
                end
                
                obj.IsNotifyWhenScansQueuedBelowAuto = logical(newValue);
                obj.WaterMarkChangeInProgress = true;
                obj.updateNotifyWhenScansQueuedBelowIfNeeded();
                obj.WaterMarkChangeInProgress = false;
                obj.resetCountersImpl();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
    end 


    %% Hidden / Read-only
    
    % Read-only properties    
    properties(Hidden, SetAccess = private)
        %Trigger and Clocking information associated with the session
        SyncManager        
        
        %Total scans transferred to hardware
        ScansTransferred                
    end    
    
    properties (SetObservable, SetAccess = private)
        %The vendor associated with the device
        Vendor
        
        %Array of all channels associated with this session.
        Channels
        
        %Array of all connections associated with this session.
        Connections
        
        %True when hardware is waiting for a trigger, operating, or there is
        %data in the process of being returned to MATLAB.
        IsRunning
        
        %True when hardware is acquiring or generating data.
        IsLogging
        
        %True if the operation in progress has been completed, and all
        %data has been output or returned.
        IsDone
        
        %True if the session in progress has received an external trigger and
        %is no longer waiting for it.
        IsWaitingForExternalTrigger
        
        %An positive non-zero double representing the number of remaining triggers.
        TriggersRemaining
        
        %The limits on the rate of the operation, given its current
        %configuration
        RateLimit
        
        %The number of scans that have been queued by the session for
        %output.
        ScansQueued
        
        %The number of scans that have been output by the hardware since
        %the startForeground or startBackground method was called.
        ScansOutputByHardware
        
        %The number of scans that have been acquired since the
        %startForeground or startBackground method was called.
        ScansAcquired
    end
    
    properties(Hidden, SetObservable, SetAccess = private)
        % Number of scans from last run
        LastRunNumberOfScans
    end
    
    properties(Hidden, SetAccess = {?daq.ISession, ?daq.interfaces.IDaq})
        FireFlushWarning = true
        DisplayAsTable = false
        FireDeletedSessionWarning = true;
        FireDurationIncreasedWarning = true;        
    end        
    
    % Lifetime
    methods(Hidden)
        function obj = Session(vendorInfo,initialRate)
            % G631826: Check the parameters to ensure that an end user isn't trying
            % to directly instantiate daq.Session.
            if nargin ~= 2 ||...
                    ~isa(vendorInfo,'daq.VendorInfo') ||...
                    ~daq.internal.isNumericNum(initialRate)
                obj.getLocalizedException('daq:Session:noDirectInstantiation').throwAsCaller();
            end
            
            daq.Session.checkLicense();
            obj.createInternalStateMap();
            obj.changeState('Initializing')
            obj.Vendor = vendorInfo;
            
            % Initialize properties for this instance.  Note that
            % initialization when the property is defined does not work the
            % same way -- it only initializes the first time the class is
            % created.  See the MATLAB class documentation for details.
            obj.InitializationInProgress = true;
            
            obj.WarnOnImplicitRelease = false;
            obj.IsReleaseInternal = false;
            obj.ChannelMediators = containers.Map();
            
            obj.DataAvailableListenerAdded = false;
            obj.RateDurationNumScanChangeInProgress = false;
            obj.RateChangeInProgress = false;
            obj.WaterMarkChangeInProgress = false;
            obj.ScanQueuingInProgress = false;
            obj.IsDurationPreferred = true;
            obj.IsWaitingForQueueOutputData = false;
            obj.IsDurationPreferred = false;
            obj.TriggerTime = [];
            obj.AcquisitionQueue = [];
            obj.GenerationQueue = [];
            obj.DataToOutputForNextTrigger = [];
            
            obj.IsContinuous = false;
            obj.IsNotifyWhenDataAvailableExceedsAuto = true;
            obj.IsNotifyWhenScansQueuedBelowAuto = true;
            obj.Channels = daq.Channel.empty;
            obj.Connections = daq.Connection.empty;
            obj.IsDone = false;
            obj.ScansQueued = uint64(0);
            obj.ScansTransferred = uint64(0);
            obj.ScansOutputByHardware = uint64(0);
            obj.ScansAcquired = uint64(0);
            obj.TotalScansAvailableNotified = uint64(0);
            % Assume an initial value of 10 seconds for External Trigger
            % timeout
            obj.ExternalTriggerTimeout = 10;
            obj.TriggersPerRun = 1;
            obj.TriggersRemaining = 1;
            
            % Create the sync manager object by requesting the class from the
            % vendor implementation, and then instantiating it
            syncObjectClassName = obj.getSyncManagerObjectClassNameHook();
            obj.SyncManager = feval(str2func(syncObjectClassName),obj);
            
            obj.InitializationInProgress = false;
            
            % Duration is set outside of initialization, so that all
            % dependent properties are set consistently.
            obj.DurationInSeconds = 1.0;
            
            % This default percentage was chosen in a previous release. If
            % the frequency of buffer overflow errors increase, this number
            % can be increased.
            obj.PercentMaximumMemoryForStreaming = 50;
            
            % Call the vendor implementation to see if they have rate
            % limits
            obj.updateRateLimitInfoHook();
            
            % Make sure the initial rate is within the RateLimits
            obj.InitialRate = initialRate;            
            obj.setRateToInitialRate();
            
            % Initialize cache            
            obj.clearSingleScanCache();
            
            % All sessions start with no channels
            obj.changeState('NoChannels')
        end
        
        function delete(obj)
            % Stop the operation in progress.  Go directly to the
            % implementation as the object is in the process of being
            % deleted, and the state classes can no longer access the
            % object.
            try
                if obj.IsRunning
                    if obj.FireDeletedSessionWarning % g2078773
                        obj.localizedWarning('daq:Session:sessionDeletedWhileRunning');
                    end
                    obj.doStop(true)
                end
            catch %#ok<CTCH>
                % Ignore any errors
            end
            
            % Delete the hardware information
            if ~isempty(obj.Channels)
                deleteRemovedChannel(obj.Channels);
            end
            
            obj.Channels = [];
        end        
    end    

    % Friend methods
    methods(Hidden)
        function setIsDone(obj,newValue)
            % The state machine needs to be able to set and clear the
            % IsDone flag as the machine transitions state
            obj.IsDone = newValue;
        end
        
        function decrementTriggersRemaining(obj)
            if obj.TriggersRemaining > 0
                obj.TriggersRemaining = obj.TriggersRemaining - 1;
                if obj.TriggersRemaining ==  0
                    obj.DataToOutputForNextTrigger = [];
                end
            end
        end
        
        function refreshTriggerRemaining(obj)
            obj.TriggersRemaining = obj.TriggersPerRun;
        end
        
        function verifyChannelPropertyUpdate(obj)
            % it may be unsafe to rely on cached values during a property
            % update
            obj.clearSingleScanCache();
            obj.errorIfParameterChangeNotOK();
        end
        
        function errorIfParameterChangeNotOK(obj)
            obj.InternalState.errorIfParameterChangeNotOK();
        end
    end
    
    %% Sealed 
    
    % Add Channels    
    methods(Sealed)
        function [channel,index] = addAnalogInputChannel(obj,varargin)
            % ADDANALOGINPUTCHANNEL will be removed in a future release. Use
            % addinput with a DataAcquisition object instead.
            %
            % Add an analog input channel to the session
            %
            % addAnalogInputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE)
            % adds an input channel, specified by CHANNELID on device
            % DEVICEID to the session.  CHANNELID may be a numeric value,
            % numeric array, string, or cell array of strings.
            % MEASUREMENTTYPE may be 'Voltage','Thermocouple', 'Current',
            % 'IEPE', etc.  These are vendor defined.  A complete list of
            % measurement types supported by a specific device is available
            % by using the daq.getDevices() function, and clicking on the device in the
            % list.
            %
            % addAnalogInputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addAnalogInputChannel(...)
            % addAnalogInputChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the index into the Channels array
            % where the channel was added.
            %
            % Example:
            %     s = daq.createSession('ni');
            %     s.addAnalogInputChannel('cDAQ1Mod1', 'ai0', 'Voltage');
            %     s.startForeground();
            %
            % See also addAnalogOutputChannel, removeChannel,
            % daq.getDevices
            
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                % G676020: To improve usability and consistency, the
                % capitalization of the measurement parameter will be
                % automatically corrected.
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(varargin{3});
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.AnalogInput, varargin{:});
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
              channel = obj.dispForNoOutputArgument();             
            end
        end
        
        function [channel,index] = addAnalogOutputChannel(obj,varargin)
            % ADDANALOGOUTPUTCHANNEL will be removed in a future release.
            % Use addoutput with a DataAcquisition object instead.
            %
            % Add an analog output channel to the session
            %
            % addAnalogOutputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE)
            % adds an output channel, specified by CHANNELID on device
            % DEVICEID to the session.  CHANNELID may be a numeric value,
            % numeric array, string, or cell array of strings.
            % MEASUREMENTTYPE may be 'Voltage', 'Current', etc.  These are
            % vendor defined.  A complete list of measurement types
            % supported by a specific device is available by using
            % the daq.getDevices() function, and clicking on the device in the list.
            %
            % addAnalogOutputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addAnalogOutputChannel(...)
            % addAnalogOutputChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the INDEX into the Channels array
            % where the channel was added.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addAnalogOutputChannel('cDAQ1Mod2', 'ao0', 'Voltage');
            %    data = sin(linspace(0, 2*pi, 1000));
            %    s.queueOutputData(data);
            %    s.startForeground();
            %
            % See also addAnalogInputChannel, removeChannel,
            % daq.getDevices
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                % G676020: To improve usability and consistency, the
                % capitalization of the measurement parameter will be
                % automatically corrected.
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(varargin{3});
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.AnalogOutput, varargin{:});
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
               channel = obj.dispForNoOutputArgument();       
            end
        end
        
        function [channel,index] = addDigitalChannel(obj,varargin)
            % ADDDIGITALCHANNEL will be removed in a future release. Use
            % addinput, addoutput, and addbidirectional with a
            % DataAcquisition object instead.
            %
            % Add a digital channel to the session
            %
            % addDigitalChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE) adds an
            % output channel, specified by CHANNELID on device adds a input
            % channel, specified by CHANNELID on device DEVICEID to the
            % session.  CHANNELID may be a string, or cell array of
            % strings. MEASUREMENTTYPE may be 'Input' or 'Output'.
            %
            % addDigitalChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addDigitalChannel(...)
            % addAnalogInputChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the index into the Channels array
            % where the channel was added.
            %
            % Example:
            %     s = daq.createSession('ni');
            %     s.addDigitalChannel('cDAQ1Mod1', 'Port0/Line0:3', 'InputOnly');
            %     s.inputSingleScan();
            %
            % See also removeChannel, daq.getDevices
            
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                % G676020: To improve usability and consistency, the
                % capitalization of the measurement parameter will be
                % automatically corrected.
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(varargin{3});
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.DigitalIO, varargin{:});
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
              channel = obj.dispForNoOutputArgument();       
            end
        end
        
        function [channel,index] = addCounterInputChannel(obj,varargin)
            % ADDCOUNTERINPUTCHANNEL will be removed in a future release.
            % Use addinput with a DataAcquisition object instead.
            %
            % Add a counter input channel to the session
            %
            % addCounterInputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE)
            % adds a input channel, specified by CHANNELID on device
            % DEVICEID to the session.  CHANNELID may be a numeric value,
            % numeric array, string, or cell array of strings.
            % MEASUREMENTTYPE may be 'EdgeCount','PulseWidth', 'Frequency',
            % 'Position', etc.  These are vendor defined.  A complete list
            % of measurement types supported by a specific device is
            % available by using the daq.getDevices() function, and
            % clicking on the device in the list.
            %
            % addCounterInputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addCounterInputChannel(...)
            % addCounterInputChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the index into the Channels array
            % where the channel was added.
            %
            % You can use counter input channels to perform on demand
            % acquisitions using inputSingleScan.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addCounterInputChannel('cDAQ1Mod3', 'ctr0', 'EdgeCount');
            %    s.inputSingleScan();
            %
            % You can also use counter input channels to perform clocked
            % operations. Some counters require an external clock. In the
            % example below, an analog input channel belonging to a device
            % on the same chassis as the counter module, is added to the
            % session to allow it to automatically configure itself to
            % share clocks with the analog input device.
            %
            % Example:
            %     s = daq.createSession('ni');
            %     s.addAnalogInputChannel('cDAQ1Mod1', 'ai0', 'Voltage');
            %     s.addCounterInputChannel('cDAQ1Mod3', 'ctr0', 'EdgeCount');
            %     s.startForeground();
            %
            % See also addCounterOutputChannel, removeChannel,
            % daq.getDevices
            
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                % G676020: To improve usability and consistency, the
                % capitalization of the measurement parameter will be
                % automatically corrected.
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(varargin{3});
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.CounterInput, varargin{:});
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
                channel = obj.dispForNoOutputArgument();
            end
        end
        
        function [channel,index] = addCounterOutputChannel(obj,varargin)
            % ADDCOUNTEROUTPUTCHANNEL will be removed in a future release.
            % Use addoutput with a DataAcquisition object instead.
            %
            % Add a counter output channel to the session
            %
            % addCounterOutputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE)
            % adds an output channel, specified by CHANNELID on device
            % DEVICEID to the session.  CHANNELID may be a numeric value,
            % numeric array, string, or cell array of strings.
            % MEASUREMENTTYPE may be 'PulseGeneration', etc.  These are
            % vendor defined.  A complete list of measurement types
            % supported by a specific device is available by using
            % the daq.getDevices() function, and clicking on the device in the list.
            %
            % addCounterOutputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addCounterOutputChannel(...)
            % addCounterOutputChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the INDEX into the Channels array
            % where the channel was added.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addCounterOutputChannel('cDAQ1Mod3', 'ctr0', 'PulseGeneration');
            %    s.Channels(1).Frequency = 100;
            %    s.startForeground();
            %
            % See also addCounterInputChannel, removeChannel,
            % daq.getDevices
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                % G676020: To improve usability and consistency, the
                % capitalization of the measurement parameter will be
                % automatically corrected.
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(varargin{3});
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.CounterOutput, varargin{:});
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
                channel = obj.dispForNoOutputArgument();                       
            end
        end        
        
        function [channel,index] = addAudioInputChannel(obj,varargin)
            % ADDAUDIOINPUTCHANNEL will be removed in a future release. Use
            % addinput with a DataAcquisition object instead.
            %
            % Add an audio input channel to the session
            %
            % addAudioInputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE)
            % adds an input channel, specified by CHANNELID on device
            % DEVICEID to the session.  CHANNELID may be a numeric value,
            % numeric array, string, or cell array of strings.
            % MEASUREMENTTYPE can be specified as 'Audio' or omitted.
            %
            % addAudioInputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addAudioInputChannel(...)
            % addAudioInputChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the index into the Channels array
            % where the channel was added.
            %
            % Example:
            %     s = daq.createSession('directsound');
            %     s.addAudioInputChannel('Audio0', '1', 'Audio');
            %     % We can optionally omit the 'MeasurementType'
            %     s.addAudioInputChannel('Audio0', '2');
            %     s.startForeground();
            %
            % See also addAudioOutputChannel, removeChannel,
            % daq.getDevices
            
            try
                % Audio permits these options:
                % Two arguments: deviceID, channelID                
                % Three arguments: deviceID, channelID, ''
                % Three arguments: deviceID, channelID, 'audio'
                % Three arguments: deviceID, channelID, 'Audio'

                if nargin < 3
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                % If we only have two measurements or an empty third
                % argument, then use 'Audio' as a default measurement
                % string. If any other third argument is provided, treat it
                % as a valid attempt.
                switch nargin
                    case 3
                        measurementString = 'Audio';
                    case 4
                        if isempty(varargin{3})
                            measurementString = 'Audio';
                        else
                            measurementString = varargin{3};
                        end
                    otherwise
                        measurementString = varargin{3};
                end      
                
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(measurementString);
                                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.AudioInput, varargin{:} );
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
              channel = obj.dispForNoOutputArgument();             
            end
        end
       
        function [channel,index] = addAudioOutputChannel(obj,varargin)
            % ADDAUDIOOUTPUTCHANNEL will be removed in a future release.
            % Use addoutput with a DataAcquisition object instead.
            %
            % Add an audio output channel to the session
            %
            % addAudioOutputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE)
            % adds an output channel, specified by CHANNELID on device
            % DEVICEID to the session.  CHANNELID may be a numeric value,
            % numeric array, string, or cell array of strings.
            % MEASUREMENTTYPE can be specified as 'Audio' or omitted.            
            %
            % addAudioOutputChannel(DEVICEID,CHANNELID,MEASUREMENTTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addAudioOutputChannel(...)
            % addAudioOutputChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the index into the Channels array
            % where the channel was added.
            %
            % Example:
            %     s = daq.createSession('directsound');
            %     s.addAudioOutputChannel('Audio4', '1', 'Audio');
            %     % We can optionally omit the 'MeasurementType'            
            %     s.addAudioOutputChannel('Audio4', '2');
            %     s.startForeground();
            %
            % See also addAudioInputChannel, removeChannel,
            % daq.getDevices
            
            try
                if nargin < 3
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                % Audio permits these options:
                % Two arguments: deviceID, channelID                
                % Three arguments: deviceID, channelID, ''
                % Three arguments: deviceID, channelID, 'audio'
                % Three arguments: deviceID, channelID, 'Audio'
                
                % If we only have two measurements or an empty third
                % argument, then use 'Audio' as a default measurement
                % string. If any other third argument is provided, treat it
                % as a valid attempt.
                switch nargin
                    case 3
                        measurementString = 'Audio';
                    case 4
                        if isempty(varargin{3})
                            measurementString = 'Audio';
                        else
                            measurementString = varargin{3};
                        end
                    otherwise
                        measurementString = varargin{3};
                end      
                
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(measurementString);               
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.AudioOutput, varargin{:} );
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
              channel = obj.dispForNoOutputArgument();             
            end
        end        
        
        function [channel,index] = addFunctionGeneratorChannel(obj,varargin)
            % ADDFUNCTIONGENERATORCHANNEL will be removed in a future
            % release. Use addoutput with a DataAcquisition object instead.
            %
            % Add a function generator channel to the session
            %
            % addFunctionGeneratorChannel(DEVICEID,CHANNELID,WAVEFORMTYPE)
            % adds an output channel, specified by CHANNELID on device
            % DEVICEID to the session.  CHANNELID may be a numeric value,
            % numeric array, string, or cell array of strings.
            % WAVEFORMTYPE can be specified 'Sine', 'Square',
            % 'Triangle', 'RampUp', 'RampDown', 'DC', or 'Arbitrary'. These
            % are vendor defined. A complete list of function generator
            % types supported by a specific device is available from the
            % device list returned by the daq.getDevices function - call
            % the function and click on the device in the list. 
            %
            % addFunctionGeneratorChannel(DEVICEID,CHANNELID,WAVEFORMTYPE,...)
            % additional parameters can be specified, and are vendor
            % specific.  See the vendor specific documentation for details.
            %
            % [CHANNEL,INDEX] = addFunctionGeneratorChannel(...)
            % addFunctionGeneratorChannel optionally returns CHANNEL, which is an
            % object representing the channel that was added.  It also
            % returns INDEX, which is the INDEX into the Channels array
            % where the channel was added.
            %
            % Example:
            %    s = daq.createSession('digilent');
            %    s.addFunctionGeneratorChannel('AD1', '1', 'Arbitrary');
            %    s.addFunctionGeneratorChannel('AD1', '2', 'Sine');
            %    s.startForeground();
            %
            % See also removeChannel, daq.getDevices
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddChannel')
                end
                
                varargin{3} = daq.internal.getCorrectMeasurementCapitalization(varargin{3});
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [channel,index] = obj.addChannelInternal(...
                    daq.internal.SubsystemType.FunctionGenerator, varargin{:});
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                daqOptions = daq.internal.getOptions();
                if daqOptions.FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % G700310: If the user did not give any output arguments,
            % display the Session object
            if nargout == 0
                channel = obj.dispForNoOutputArgument();                       
            end
        end
    end
    
    % API
    methods(Sealed)

        function [conn,index] = addTriggerConnection(obj,varargin)
            % ADDTRIGGERCONNECTION will be removed in a future release. Use
            % addtrigger with a DataAcquisition object instead.
            %
            % Add a trigger connection to the session
            %
            % s.addTriggerConnection(source,destination,type) establishes a trigger
            % from the specified source to the specified destination of the specified
            % connection type.
            %
            % tc = s.addTriggerConnection(source,destination,type) establishes a
            % trigger from the specified source to the specified destination of the
            % specified connection type and displays it in the variable tc.
            %
            % [tc, idx]= s.addTriggerConnection(source,destination,type) establishes a
            % trigger from the specified source to the specified destination of the
            % specified connection type and displays the connection in the variable tc
            % and the connection index, idx.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addAnalogInputChannel('Dev1','ai0', 'Voltage')
            %    s.addAnalogInputChannel('Dev2','ai0', 'Voltage')
            %    s.addTriggerConnection('Dev1/PFI4','Dev2/PFI0','StartTrigger')
            %    s.startForeground();
            %
            % See also addClockConnection, removeConnection,
            % daq.getDevices
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddTriggerConnection')
                end
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [conn,index] = obj.addTriggerConnectionInternal(varargin{:});
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % If the user did not give any output arguments,
            % display the connection object
            if nargout == 0
                conn = evalc('disp(obj.Connections)');
                conn = char(strip(string(conn)));
            end
        end
        
        function [conn,index] = addClockConnection(obj,varargin)
            % ADDCLOCKCONNECTION will be removed in a future release. Use
            % addclock with a DataAcquisition object instead.
            %            
            % Add a clock connection to the session
            %
            % s.addClockConnection(source,destination,type) adds a clock
            % from the specified source to the specified destination of the
            % specified connection type.
            %
            % cc = s.addClockConnection(source,destination,type) adds a
            % clock from the specified source to the specified destination
            % of the specified connection type and displays it in the
            % variable cc.
            %
            % [cc, idx]= s.addClockConnection(source,destination,type) adds
            % a clock from the specified source to the specified
            % destination of the specified connection type and displays the
            % connection it in the variable cc and the connection index,
            % idx.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addAnalogInputChannel('Dev1','ai0', 'Voltage')
            %    s.addAnalogInputChannel('Dev2','ai0', 'Voltage')
            %    s.addClockConnection('Dev1/PFI4','Dev2/PFI0','ScanClock')
            %    s.startForeground();
            %
            % See also addTriggerConnection, removeConnection,
            % daq.getDevices
            
            try
                if nargin < 4
                    obj.localizedError('daq:Session:notEnoughArgForAddClockConnection')
                end
                
                % This is effectively a convenience function.  Call
                % addChannelInternal to do the real work
                [conn,index] = obj.addClockConnectionInternal(varargin{:});
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            % If the user did not give any output arguments,
            % display the connection object
            if nargout == 0
                conn = evalc('disp(obj.Connections)');
                conn = char(strip(string(conn)));
            end
        end
        
        function removeChannel(obj,index)
            % removeChannel with a Session object will be removed in a
            % future release. Use removechannel with a DataAcquisition
            % object instead.
            %            
            % Remove a channel from the session
            %
            % removeChannel(INDEX) removes the channel at INDEX location in
            % the Channels array of the session
            %
            % See also addAnalogInputChannel, addAnalogOutputChannel
            
            try
                % Delegate to the state objects. If it is a valid operation, it will
                % come back as doRemoveChannel
                obj.InternalState.removeChannel(index);                
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function removeConnection(obj,index)
            % REMOVECONNECTION will be removed in a future release. Use
            % removechannel or removeclock with a DataAcquisition object
            % instead.
            %            
            % Remove a connection from the session
            %
            % removeConnection(INDEX) removes the connection at INDEX location in
            % the Connections array of the session
            %
            % See also addTriggerConnection, addClockConnection
            try
                % Delegate to the state objects. If it is a valid operation, it will
                % come back as doRemoveChannel
                obj.InternalState.removeConnection(index);
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function prepare(obj)
            % PREPARE will be removed in a future release. 
            %            
            % Prepare a session for operations
            % prepare() is optional.  To reduce the latency of future calls
            % to startBackground and startForeground, call prepare() to
            % configure and allocate hardware, etc.
            %
            % See also release, startForeground, startBackground
            try
                % Delegate to the state objects. If it is a valid operation, it will
                % come back as doPrepare
                obj.InternalState.prepare();
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function [data, time, triggerTime] = startForeground(obj)
            % STARTFOREGROUND will be removed in a future release. Use
            % read, write, or readwrite with a DataAcquisition object
            % instead.
            %            
            % startForeground() starts the hardware operations specified by
            % the session.  MATLAB will block until the operation is
            % complete, and data is returned. To acquire and generate data
            % while MATLAB continues to execute, use startBackground.
            %
            % [DATA,TIMESTAMPS,TRIGGERTIME] = startForeground()
            % startForeground returns the data acquired (if any) in an mxn
            % array of doubles, DATA, where m is the number of scans acquired,
            % and n is the number of input channels in the session.
            % TIMESTAMPS is a mx1 array of timestamps relative to the time the
            % operation is triggered.  TRIGGERTIME is a MATLAB serial
            % date time stamp representing timestamp of 0.
            %
            % If a session includes output channels, you must call
            % queueOutputData() before calling startForeground().
            %
            % Continuous operations cannot be done using startForeground().
            %
            % See also release, startBackground, queueOutputData
            try
                obj.LastRunNumberOfScans = obj.NumberOfScans;
                
                % Delegate to the state objects. If it is a valid operation, it will
                % come back as doStartForeground
                if nargout == 0 && obj.Channels.countInputChannels() == 0
                    % G635541: If the user didn't ask for output
                    % parameters, and there's no analog input channels,
                    % then don't return data.
                    obj.InternalState.startForeground();
                else
                    [data, time, triggerTime] = obj.InternalState.startForeground();
                end
            catch e
                % G732799: If the startForeground operation errors, make
                % sure we return to an unprepared state.
                % Stop the session before we release it.
                obj.stop();
                
                % G1007273: If release fails in this catch block, it should
                % not mask out the original error message.
                try 
                    obj.releaseInternal(); 
                catch %#ok<CTCH>
                end
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            obj.refreshTriggerRemaining();
        end
        
        function startBackground(obj)
            % STARTBACKGROUND will be removed in a future release. Use
            % start with a DataAcquisition object instead.
            %            
            % Start a background, non-blocking operation and return control
            % to MATLAB command line processing immediately, allowing other
            % MATLAB code to run in parallel with startBackground. To block
            % MATLAB execution and wait while acquiring or generating data
            % use startForeground.
            %
            % Use addlistener to add an event listener when performing
            % a background acquisition. The DataAvailable event is
            % called periodically when data is available. The following is
            % an example to plot analog input data while it is being
            % acquired. The live plot shows the most recent block of acquired
            % data versus time.
            %
            % Example:
            %     s = daq.createSession('ni');
            %     s.addAnalogInputChannel('cDAQ1Mod1', 'ai0', 'Voltage');
            %     lh = s.addlistener('DataAvailable', ...
            %         @(src,event) plot(event.TimeStamps, event.Data));
            %     s.startBackground();
            %     delete(lh);
            %
            % If a session includes output channels, call queueOutputData()
            % before calling startBackground(). During continuous generation,
            % the DataRequired event is called periodically to request
            % additional data to be queued to the session. The following is
            % an example to continuously queue output data to be generated
            % by an analog output device.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addAnalogOutputChannel('cDAQ1Mod2', 'ao0', 'Voltage');
            %    s.IsContinuous = true;
            %    data = sin(linspace(0, 2*pi, 1001));
            %    data(end) = [];
            %    s.queueOutputData(data);
            %    lh = s.addlistener('DataRequired', ...
            %       @(src,event) src.queueOutputData(data));
            %    s.startBackground();
            %    delete(lh);
            %
            % You can stop background operations with the stop() command.
            %
            % See also startForeground, <a href="matlab:help daq.DataAvailable">DataAvailable</a>, <a href="matlab:help daq.DataRequired">DataRequired</a>, <a href="matlab:help daq.ErrorOccurred">ErrorOccurred</a>, handle.addlistener, queueOutputData, stop, wait
            try
                obj.LastRunNumberOfScans = obj.NumberOfScans;
                
                % Delegate to the state objects. If it is a valid operation, it will
                % come back as doStartBackground
                obj.InternalState.startBackground();
            catch e
                % G732799: If the startBackground operation errors, make
                % sure we return to an unprepared state.
                obj.releaseInternal();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            obj.refreshTriggerRemaining();
        end
        
        function wait(obj,timeout)
            % WAIT will be removed in a future release. 
            %            
            % Block MATLAB until a background operation completes
            %
            % wait() blocks MATLAB indefinitely until the operation in progress is
            % complete.  You can use ctrl-C to abort this operation.
            %
            % wait(TIMEOUT) blocks MATLAB until the operation in progress is
            % complete.  TIMEOUT is the maximum number of seconds that
            % can elapse before an error occurs.
            %
            % Any callbacks or events generated while wait() is blocking
            % will be executed.
            %
            % See also startBackground, stop, <a href="matlab:help daq.DataAvailable">DataAvailable</a>, <a href="matlab:help daq.DataRequired">DataRequired</a>
            if nargin < 2
                timeout = Inf;
            end
            try
                % Delegate to the state objects. If it is a valid operation, it will
                % come back as doWait
                obj.InternalState.wait(timeout);
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function stop(obj,noWait)
            % STOP for session will be removed in a future release. Use
            % stop with a DataAcquisition object instead.
            %            
            % Stop a background operation
            % stop() stops the hardware operations in progress
            %
            % If there are data that have been acquired, then these data
            % are left undelivered (no further DataAvailable events are
            % fired).
            %
            % See also prepare, release, startBackground, stop, wait
            
            
            % noWait is an undocumented functionality that may be removed
            % in a future release.  When this optional parameter is set
            % true, the stop method will not wait for IsRunning to go to
            % false.  This functionality is used by the automated test
            % system to verify the state machine functionality.
            if nargin < 2
                noWait = false;
            end
            
            try
                % Delegate to the state objects. If it is a valid operation, it will
                % come back as doStop
                obj.InternalState.stop(noWait);
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function queueOutputData(obj,data)
            % QUEUEOUTPUTDATA will be removed in a future release. Use
            % preload or write with a DataAcquisition object instead.
            %            
            % Queue clocked data to be generated using startForeground /
            % startBackground.
            % queueOutputData(DATA) queues DATA to the hardware. DATA is an
            % mxn array of doubles, where m is the number of scans to
            % generate, and n is the number of output channels in the
            % session.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addAnalogOutputChannel('cDAQ1Mod2', 'ao0', 'Voltage');
            %    data = sin(linspace(0, 2*pi, 1000));
            %    s.queueOutputData(data);
            %    s.startForeground();
            %
            % See also startForeground, startBackground, addAnalogOutputChannel
            
            try
                % Delegate to the state objects (if valid operation, it will
                % come back as doQueueOutputData
                obj.InternalState.queueOutputData(data);
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function [data,triggerTime] = inputSingleScan(obj)
            % INPUTSINGLESCAN will be removed in a future release. Use
            % read with a DataAcquisition object instead.
            %            
            % inputSingleScan Acquire a single scan of data from input
            % channels on the session.
            % [DATA,TRIGGERTIME] = inputSingleScan() returns the data
            % acquired in a 1xn array of doubles, DATA, where n is the
            % number of input channels in the session. TRIGGERTIME is a
            % MATLAB serial date time stamp representing the time the data
            % was acquired.
            %
            % inputSingleScan can be used with analog or digital input
            % channels to acquire a single scan of data across all input
            % channels in a session.
            %
            % Example:
            %    s = daq.createSession('ni');
            %    s.addAnalogInputChannel('cDAQ1Mod1', 1:2, 'Voltage');
            %    s.inputSingleScan();
            %
            % Example to count number of edges over 1 second:
            %    s = daq.createSession('ni');
            %    s.addCounterInputChannel('cDAQ1Mod3', 'ctr0', 'EdgeCount');
            %    s.resetCounters();
            %    pause(1);
            %    s.inputSingleScan();
            %
            % To acquire multiple scans using clocked operations, see
            % startForeground
            %
            % See also outputSingleScan, startForeground
            try
                % Call the channels to give them a chance to validate before
                % starting an operation
                obj.Channels.errorIfNotReadyToStart();
                
                % Delegate to the state objects. If it is a valid
                % operation, it will come back as doInputSingleScan
                [data,triggerTime] = obj.InternalState.inputSingleScan();
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function outputSingleScan(obj,data)
            % OUTPUTSINGLESCAN will be removed in a future release. Use
            % write with a DataAcquisition object instead.
            %             
            % outputSingleScan Write a single scan of data to output
            % channels in the session. The value remains on the output
            % terminal until another value is written.
            % outputSingleScan(DATA) outputs DATA, a 1xn array of doubles
            % where n is the number of output channels in the session.
            %
            % outputSingleScan can be used with analog or digital output
            % channels to generate a single scan of data across all output
            % channels in a session.
            %
            % To generate multiple (clocked) scans, use startForeground
            %
            % See also inputSingleScan, startForeground, queueDataForOutput
            
            try
                % Call the channels to give them a chance to validate before
                % starting an operation
                obj.Channels.errorIfNotReadyToStart();
                
                % Delegate to the state objects. If it is a valid
                % operation, it will come back as doOutputSingleScan
                obj.InternalState.outputSingleScan(data);
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function release(obj)
            % RELEASE will be removed in a future release. Use
            % stop and flush with a DataAcquisition object instead.
            %             
            % Release resources associated with a session
            % release() is optional.  It is symmetric to prepare(), and
            % releases hardware, deallocates buffers, etc.
            %
            % See also prepare, startForeground, startBackground
            try
                % Delegate to the state objects. If it is a valid
                % operation, it will come back as release
                obj.InternalState.release();
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
        
        function resetCounters(obj)
            % resetCounters with a Session object will be removed in a
            % future release. Use resetcounters with a DataAcquisition
            % object instead.
            %             
            % Used to reset counter input channels for use with
            % inputSingleScan method.
            %
            % See also inputSingleScan
            try
                % Delegate to the state objects. If it is a valid
                % operation, it will come back as doResetCounters
                obj.InternalState.resetCounters();
            catch e
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
        end
    end
    
    % State-machine methods. See also API, state-machine helper methods
    methods(Hidden, Sealed)
        % These actually implement the action, once the choice has been
        % made by the state class to do the action.  Once we have friend
        % methods, this would likely move to the state classes, as they'll
        % have direct access to the Session internal state.
        
        function changeState(obj,targetState)
            % changeState switch session to the target state
            % Intended only for use internally, or by State* classes
            try
                if daq.internal.getOptions().StateDebug
                    disp(['Session State : ' targetState]);
                end
                % Pull the target state out of the map
                obj.InternalState = obj.InternalStateMap(targetState);
            catch e
                if strcmp(e.identifier,'MATLAB:Containers:Map:NoKey')
                    obj.localizedError('daq:Session:badState',targetState)
                else
                    rethrow(e)
                end
            end
            
            % Update the IsRunning, IsLogging and IsWaitingForExternalTrigger
            % flags from the state
            obj.IsLogging = obj.InternalState.getIsLoggingFlag();
            obj.IsRunning = obj.InternalState.getIsRunningFlag();
            obj.IsWaitingForExternalTrigger = obj.InternalState.getIsWaitingForExternalTriggerFlag();
            
            % Switch to the new state
            obj.InternalStateName = targetState;
        end
        
        function [channel,index] = addChannelInternal(obj,varargin)
            % Implements the addAnalogInput and addAnalogOutput convenience
            % functions
            
            % Delegate to the state objects. If it is a valid operation, it
            % will come back as doAddChannel
            daq.Session.checkLicense();
            [channel,index] = obj.InternalState.addChannel(varargin{:});
        end
        
        function [channel,index] = addTriggerConnectionInternal(obj,varargin)
            % Delegate to the state objects. If it is a valid operation, it
            % will come back as doAddTriggerConnection
            daq.Session.checkLicense();
            [channel,index] = obj.InternalState.addTriggerConnection(varargin{:});
        end
        
        function [channel,index] = addClockConnectionInternal(obj,varargin)
            % Delegate to the state objects. If it is a valid operation, it
            % will come back as doAddClockConnection
            daq.Session.checkLicense();
            [channel,index] = obj.InternalState.addClockConnection(varargin{:});
        end
        
        function [newChannels,indexNewChannels] = doAddChannel(...
                obj,subsystem,deviceID,channelID,measurementType,varargin)
            % Validate subsystem type
            if ~isa(subsystem,'daq.internal.SubsystemType') ||...
                    subsystem == daq.internal.SubsystemType.Unknown
                obj.localizedError('daq:Session:invalidSubsystem')
            end
            
            % Validate deviceID
            if ~isempty(deviceID) && daq.internal.isNumericNum(deviceID) && isscalar(deviceID)
                % Numeric scalars are OK as deviceID, but they are cast
                % to strings
                deviceID = num2str(deviceID);
            end
            if isempty(deviceID) || ~daq.internal.isScalarStringOrCharVector(deviceID)
                obj.localizedError('daq:Session:invalidDeviceID')
            else
                deviceID = char(deviceID);
            end
            
            % Check if the device is known

            % g873066,873097,885613: Fixed LXE incompatibility warnings
            HardwareInfo = daq.HardwareInfo.getInstance(); 
            devices = HardwareInfo.Devices;

            theDevice = devices.locate(obj.Vendor.ID, deviceID);
            if isempty(theDevice)
                % G639289 If there are no devices available say so
                % explicitly.
                if isempty(devices.locate(obj.Vendor.ID))
                    obj.localizedError('daq:Session:noDevicesAvailable');
                end
                % If not, get a list of all devices for this vendor, and
                % render as a list
                validDeviceIDs = obj.renderCellArrayOfStringsToString({devices.locate(obj.Vendor.ID).ID},', ');
                
                deviceCorrespondsToVendor = arrayfun(@(vendor) ~isempty(devices.locate(vendor.ID, deviceID)), HardwareInfo.KnownVendors);
                
                if any(deviceCorrespondsToVendor)
                    correspondingVendors = {HardwareInfo.KnownVendors(deviceCorrespondsToVendor).ID};
                    correspondingVendorsString = obj.renderCellArrayOfStringsToString(correspondingVendors,', ');
                    obj.localizedError('daq:Session:foreignDeviceID', deviceID, correspondingVendorsString, obj.Vendor.ID, validDeviceIDs)
                else
                    obj.localizedError('daq:Session:unknownDeviceID', deviceID, validDeviceIDs)
                end
            end
            
            % Make sure this device supports the requested subsystem
            deviceSubsystem = theDevice.getSubsystem(subsystem);
            if isempty(deviceSubsystem)
                obj.localizedError('daq:Session:subsystemNotPresent',  subsystem.char())
            end
            
            % Validate channelID (we can't check if it's known -- the
            % vendor has to do that
            % Note that isvector on a scalar returns true
            
            if isempty(channelID) ||...
              ~isvector(channelID) ||...
              ~( daq.internal.isNumericNum(channelID) || ...
                 daq.internal.isScalarStringOrCharVector(channelID) || ...
                 iscellstr(channelID) ) || ...
              ( isnumeric(channelID) && any (channelID < 0) ) %#ok<ISCLSTR>
                
                if ~isscalar(channelID)
                    obj.localizedError('daq:Session:invalidChannelID')
                end
                
                obj.throwUnknownChannelIDError(...
                    theDevice,...
                    num2str(channelID),...
                    theDevice.getSubsystem(subsystem).ChannelNames)
            end
            
            % channelID is always passed to the vendor implementation as a
            % either a numeric vector or a cell array of strings, to simplify processing at that end
            if daq.internal.isScalarStringOrCharVector(channelID)
                channelID = cellstr(channelID);
            end
            
            % Validate measurementType
            if ~daq.internal.isScalarStringOrCharVector(measurementType)
                obj.localizedError('daq:Session:invalidMeasurementType')
            else
                measurementType = char(measurementType);
            end
            
            % Check if it is supported
            measurementTypesAvailable = theDevice.getSubsystem(subsystem).MeasurementTypesAvailable;
            
            % Check against the list of measurements supported at the
            % current time.  If it's 'all', then skip the check.
            switch subsystem
                case {daq.internal.SubsystemType.AnalogInput, daq.internal.SubsystemType.AnalogOutput}
                    if ~strcmp(daq.internal.getOptions().SupportedSpecializedMeasurements{1},'all')
                        measurementTypesAvailable = intersect(daq.internal.getOptions().SupportedSpecializedMeasurements, measurementTypesAvailable);
                    end
                case {daq.internal.SubsystemType.DigitalIO}
                    if ~strcmp(daq.internal.getOptions().SupportedDigitalMeasurements{1},'all')
                        measurementTypesAvailable = intersect(daq.internal.getOptions().SupportedDigitalMeasurements, measurementTypesAvailable);
                    end
                case {daq.internal.SubsystemType.CounterInput, daq.internal.SubsystemType.CounterOutput}
                    if ~strcmp(daq.internal.getOptions().SupportedCounterMeasurements{1},'all')
                        measurementTypesAvailable = intersect(daq.internal.getOptions().SupportedCounterMeasurements, measurementTypesAvailable);
                    end
                case {daq.internal.SubsystemType.AudioInput, daq.internal.SubsystemType.AudioOutput}
                    if ~strcmp(daq.internal.getOptions().SupportedAudioMeasurements{1},'all')
                        measurementTypesAvailable = intersect(daq.internal.getOptions().SupportedAudioMeasurements, measurementTypesAvailable);
                    end
                case {daq.internal.SubsystemType.FunctionGenerator}
                    if ~strcmp(daq.internal.getOptions().SupportedFGenMeasurements{1},'all')
                        measurementTypesAvailable = intersect(daq.internal.getOptions().SupportedFGenMeasurements, measurementTypesAvailable);
                    end                    
                otherwise
                    % Do nothing in this case
            end
            
            if ~ismember(measurementType,measurementTypesAvailable)
                obj.localizedError('daq:Session:unknownMeasurementType',...
                    measurementType,...
                    obj.renderCellArrayOfStringsToString(measurementTypesAvailable,''', '''))
            end
            
            % Call the vendor Implementation to create the channel for us
            if subsystem == daq.internal.SubsystemType.DigitalIO
                if strcmpi(measurementType, 'InputOnly')
                    measurementTypeChannels = deviceSubsystem.DIPhysicalChans;
                elseif strcmpi(measurementType, 'OutputOnly')
                    measurementTypeChannels = deviceSubsystem.DOPhysicalChans;
                elseif strcmpi(measurementType, 'Bidirectional')
                    measurementTypeChannels = union(deviceSubsystem.DIPhysicalChans, deviceSubsystem.DOPhysicalChans);
                end
                
                if isnumeric(channelID)
                    channelID = num2str(channelID);
                end
                
                channels = obj.parseChannelsHook(subsystem, channelID);
                
                supportedChannels = intersect(measurementTypeChannels, channels);
                unsupportedChannels = setxor(supportedChannels, channels);
                if ~isempty(unsupportedChannels)
                    obj.localizedError('daq:Session:unsupportedChannels',...
                        measurementType,...
                        obj.renderCellArrayOfStringsToString(unsupportedChannels, ', '),...
                        obj.renderCellArrayOfStringsToString(measurementTypeChannels, ', '));
                end
            else
                channels = obj.parseChannelsHook(subsystem, channelID);
            end
            
            isGroup = false;
            
            if ~isempty(obj.RateLimitInfo)
                % If there is a current RateLimit, Check the rate limits
                % associated with the new channel to ensure that it
                % intersects with the channels that are already in the
                % session.
                newChannelRateLimit = deviceSubsystem.RateLimitInfo;
                incompatibleDevicesPresent = false;
                if newChannelRateLimit.Min > obj.RateLimitInfo.Max ||...
                   newChannelRateLimit.Max < obj.RateLimitInfo.Min
                    % If the channels in the session are On-demand and the
                    % newly added channel supports On-demand operations then
                    % do not throw the error
                    if obj.RateLimitInfo.Min == 0 && ...
                            obj.RateLimitInfo.Max == 0 && ...
                            any(~[deviceSubsystem.OnDemandOperationsSupported])
                        incompatibleDevicesPresent = true;
                    end
                end
                
                % G1900910: If added channel is on-demand only and the session
                % contains a channel that doesn't support on-demand operations,
                % throw an error
                if (newChannelRateLimit.Min == 0) && ...
                        (newChannelRateLimit.Max == 0) && ...
                        any(~[obj.Channels.OnDemandOperationsSupported])
                    incompatibleDevicesPresent = true;
                end

                if incompatibleDevicesPresent
                    obj.localizedError('daq:Session:incompatibleDevices',...
                            join(string(channels), ', '),...
                            deviceID);
                end
            end
            
            newChannels = obj.createChannelImpl(subsystem,...
                isGroup,... % left in for backward compatibility with existing sessions
                theDevice,...
                channels,...
                measurementType,...
                varargin{1:end});
            
            % Make sure vendor returned a daq.Channel object
            if ~isa(newChannels,'daq.Channel')
                obj.localizedError('daq:Session:invalidChannelFromVendor')
            end
            
            if any(~[newChannels.OnDemandOperationsSupported])
                obj.localizedWarning('daq:Session:clockedOnlyChannelsAdded')
            end
            
            % Add to channels property list
            startIndex = numel(obj.Channels) + 1;
            obj.Channels = [obj.Channels newChannels];
            indexNewChannels = startIndex:numel(obj.Channels);
            obj.channelsChangedHook();
            
            % if the number/type of channels changes, clear the cache
            obj.clearSingleScanCache();
            
            % If it's an output channel, then flush any data queued 
            obj.flushIfOutputChannelsUpdated(subsystem, measurementType);
            
            % If the device is not recognized, throw a warning message
            theDevice.warnOnUnrecognizedDeviceAttempt();
            
            % Recalculate rate limits based on changed configuration
            obj.updateRateLimitInfoHook();
            
            % This is to write the Session rate to the device after the
            % channel is added.
            obj.Rate = obj.Rate;
            
            obj.resetCountersImpl();
        end
        
        function [newConnections,indexNewConns] = doAddTriggerConnection(obj,...
                source,...
                destination,...
                type,....
                varargin)
            
            % Call the SyncManager to validate/correct/reconstruct
            % source argument.
            source = obj.SyncManager.validateAndCorrectSource(source);
            
            % Call the SyncManger to validate/correct/reconstruct
            % connection type.
            type = obj.SyncManager.validateAndCorrectTriggerType(type);
            
            % Destination is always passed to the vendor implementation as a
            % cell array of strings, to simplify processing at that end
            
            if daq.internal.isScalarStringOrCharVector(destination)
                destination = cellstr(destination);
            end
            
            % Loop through the number of destinations.
            %
            % Functional Spec 13.1
            % The destination RHS argument can be a cell array consisting
            % of various <Device/Terminal> format.
            %
            % The number of  connections created will be equal to the
            % number of destinations.
            try
                newConnections = daq.Connection.empty(0,numel(destination));
                for index = 1:numel(destination)
                    
                    % Call the SyncManager to validate/correct/reconstruct destination argument
                    destination{index} = obj.SyncManager.validateAndCorrectDestination(...
                        destination{index});
                    
                    % Call the vendor implementation to create a connection for us
                    newConnections(index) = obj.createTriggerConnImpl(source,destination{index},type);
                    
                    % Inform the sync manager that a connection was added.
                    obj.SyncManager.connectionBeingAdded(newConnections(index));
                    
                end
            catch e
                deleteRemovedConnection(newConnections)
                rethrow(e);
            end
            
            % Add to channels property list
            startIndex = numel(obj.Connections) + 1;
            obj.Connections = [obj.Connections newConnections];
            indexNewConns = startIndex:numel(obj.Connections);
            
            
        end
        
        function [newConnections,indexNewConns] = doAddClockConnection(obj,...
                source,...
                destination,...
                type,....
                varargin)
            
            % Call the SyncManager to validate/correct/reconstruct
            % source argument.
            source = obj.SyncManager.validateAndCorrectSource(source);
            
            % Call the SyncManger to validate/correct/reconstruct
            % connection type.
            type = obj.SyncManager.validateAndCorrectClockType(type);
            
            % Destination is always passed to the vendor implementation as a
            % cell array of strings, to simplify processing at that end
           
            if daq.internal.isScalarStringOrCharVector(destination)
                destination = cellstr(destination);
            end            
            
            % Loop through the number of destinations.
            %
            % Functional Spec -13.1
            % The destination RHS argument can be a cell array consisting
            % of various <Device/Terminal> format.
            %
            % The number of  connections created will be equal to the
            % number of destinations.
            try
                newConnections = daq.Connection.empty(0,numel(destination));
                for index = 1:numel(destination)
                    
                    % Call the SyncManager to validate/correct/reconstruct destination argument
                    destination{index} = obj.SyncManager.validateAndCorrectDestination(...
                        destination{index});
                    
                    % Call the vendor implementation to create a connection for us
                    newConnections(index) = obj.createClockConnImpl(source,destination{index},type);
                    
                    obj.SyncManager.connectionBeingAdded(newConnections(index));
                end
            catch e
                deleteRemovedConnection(newConnections)
                rethrow(e);
                
            end
            
            % Add to channels property list
            startIndex = numel(obj.Connections) + 1;
            obj.Connections = [obj.Connections newConnections];
            indexNewConns = startIndex:numel(obj.Connections);
            
            
        end
        
        function doRemoveChannel(obj,index)
            
            if nargin ~= 2 || isempty(index) || ~daq.internal.isNumericNum(index) ||...
                    ~isvector(index) || any(index(:) < 1) || any(index(:) > numel(obj.Channels))
                obj.localizedError('daq:Session:invalidChannelIndex')
            end
            
            deviceIDsBeingRemoved = cell(0,0);
            channelsBeingRemovedKey = cell(0,0);
            
            for iIndex = 1:numel(index)
                % Capture the device ID of the channel to be removed to allow
                % notification of the sync manager object that a device has been
                % removed
                deviceIDsBeingRemoved{end+1} = obj.Channels(index(iIndex)).Device.ID; %#ok<AGROW>
                
                channelsBeingRemovedKey{end +1} = [obj.Channels(index(iIndex)).ID...
                    ,obj.Channels(index(iIndex)).Device.ID ....
                    ,char(obj.Channels(index(iIndex)).SubsystemType)]; %#ok<AGROW>
            end
            
            for iIndex = 1:numel(index)
                
                % Construct a map of channel IDs with their indices. This
                % is used because the channel index changes when the
                % channels are deleted.
                channelIDMap = containers.Map;
                for i = 1:numel(obj.Channels)
                    str = [obj.Channels(i).ID...
                        ,obj.Channels(i).Device.ID...
                        ,char(obj.Channels(i).SubsystemType)];
                    channelIDMap(str) = i;
                end
                
                deviceIDBeingRemoved = deviceIDsBeingRemoved{iIndex};
                channelBeingRemovedKey = channelsBeingRemovedKey{iIndex};
                
                indexBeingRemoved = channelIDMap(channelBeingRemovedKey);
                % Call the template method to give the vendor the chance to
                % abort or execute the channel removal
                obj.removeChannelHook(indexBeingRemoved)
                
                % If it's an output channel, flush any data queued
                subsystem = obj.Channels(indexBeingRemoved).SubsystemType;
                measurementType = obj.Channels(indexBeingRemoved).MeasurementType;
                
                obj.flushIfOutputChannelsUpdated(subsystem, measurementType);
                
                channelToRemove = obj.Channels(indexBeingRemoved);
                
                % Remove the Channel from the list
                obj.Channels(indexBeingRemoved) = [];
                
                % Check to see if there are no other channel in the session with
                % that device ID.  If not, Notify the sync manager object that a device
                % has been removed
                if isempty(obj.Channels)
                    obj.SyncManager.channelBeingRemoved(deviceIDBeingRemoved)
                else
                    deviceList = [obj.Channels.Device];
                    if ~any(strcmpi(deviceIDBeingRemoved,{deviceList.ID}))
                        obj.SyncManager.channelBeingRemoved(deviceIDBeingRemoved)
                    end
                end
                
                % G672220 Notify the vendor if session.Channels property
                % changed
                obj.channelsChangedHook();
                deleteRemovedChannel(channelToRemove);
                
                % if the number/type of channels changes, clear the cache
                obj.clearSingleScanCache();
            end
            
            % Recalculate rate limits based on changed configuration
            obj.updateRateLimitInfoHook();
            obj.resetCountersImpl();
        end
        
        function doRemoveConnection(obj,index)
            
            if nargin ~= 2 || isempty(index) || ~daq.internal.isNumericNum(index) ||...
                    ~isvector(index) || any(index(:) < 1) || any(index(:) > numel(obj.Connections))
                obj.localizedError('daq:Conn:invalidConnectionIndex')
            end
            
            obj.removeConnectionHook(index);
            
            % Remove the Connection from the list
            obj.Connections(index) = [];
            
            % changing the number of connections may require vendors to
            % clear the cache
            obj.clearSingleScanCache();            
        end
        
        function doPrepare(obj,isExplicitCommandByUser)
            % Call the channels to give them a chance to validate before
            % starting an operation
            obj.Channels.errorIfNotReadyToStart();
            
            % Record if this call to prepare was explicitly done by the
            % user, so we can warn if release is called as a side effect of
            % another action
            obj.WarnOnImplicitRelease = isExplicitCommandByUser;
            
            % Call the template method to give the vendor the chance to
            % prepare for an operation
            try
                obj.prepareHook();
            catch e
                obj.forceResetCounters();
                
                % Rethrow any errors as caller, removing the long stack of
                % errors -- capture the full exception in the cause field
                % if FullDebug option is set.
                if daq.internal.getOptions().FullDebug
                    rethrow(e)
                end
                e.throwAsCaller()
            end
            
            obj.transferAccumulatedOutputScansToVendor();
        end
        
        function [data, time, triggerTime] = doStartForeground(obj)
            daq.Session.checkLicense();

            if obj.IsContinuous
                obj.localizedError('daq:Session:noForegroundStartWithContinuous')
            end
            
            if obj.TriggersPerRun == Inf
                obj.localizedError('daq:Session:noForegroundStartWithInfTriggersPerRun');
            end
            
            if obj.ExternalTriggerTimeout == Inf
                obj.localizedError('daq:Session:noForegroundStartWithInfExternalTriggerTimeout');
            end
            
            obj.validateChannels()
            obj.configureAcquisitionBuffersForStart()
            
            % Initialize the buffers to hold the results
            try
                
                currentIndex = 1;
                dataAvailableListener = [];
                
                errorCapture = [];
                
                % Add a DataAvailable listener to capture the results, if
                % there are input channels
                errorOccurredListener = addlistener(obj,'ErrorOccurred',@captureError);
                
                inputChannelCount = obj.Channels.countInputChannels;
                if  inputChannelCount > 0
                    data = zeros(obj.NumberOfScans * obj.TriggersPerRun,inputChannelCount);
                    time = zeros(obj.NumberOfScans * obj.TriggersPerRun,1);
                    triggerTime = [];
                    
                    % Add a DataAvailable listener to capture the results, if
                    % there are input channels
                    prevDataAvailableListenerAdded = obj.DataAvailableListenerAdded;
                    dataAvailableListener = addlistener(obj,'DataAvailable',@queueResults);
                else
                    data = [];
                    time = [];
                    triggerTime = [];
                end
                
                % Call the vendor to start the hardware
                obj.startHardware();
                
                % Delegate the waiting for timeout to the state machine.
                % The timeout time is different for 'HardwareRunning'
                % and 'HardwareWaitingForTrigger' state.
                obj.InternalState.checkForTimeout();
                
                % Delete the listener
                if ~isempty(dataAvailableListener)
                    delete(dataAvailableListener)
                    obj.DataAvailableListenerAdded = prevDataAvailableListenerAdded;
                end
                
                if ~isempty(errorOccurredListener)
                    delete(errorOccurredListener)
                end
            catch e
                % Delete the listener, if there was an error
                if ~isempty(dataAvailableListener)
                    delete(dataAvailableListener)
                    obj.DataAvailableListenerAdded = prevDataAvailableListenerAdded;
                end
                if ~isempty(errorOccurredListener)
                    delete(errorOccurredListener)
                end
                
                % g910589: Calling stop as part of a foreground operation is
                % unsupported. When users call explicitly, it should
                % error out. However, in this context, we do not want
                % it masking out the error in the main 'catch' block: 
                try
                    obj.stopImpl();
                catch err %#ok<NASGU>
                    % Do nothing with the error.
                end
                
                % If an error occurred during a callback also i.e. with the
                % 'ErrorOccurred' event, we should throw it instead of any
                % subsequent errors. 
                throwErrorOccurred();
                
                % Check if we have Pulse-Width or Frequency Counter Inputs
                % in the session. A time out with these channels can be due
                % to the incorrect rate setting
                if strcmp(e.identifier,'daq:Session:timeout') && ....
                        (numberOfPulseWidthOrFreqCIChanPresent >= 1)
                    obj.localizedError('daq:Session:lowScanRate');
                elseif strcmp(e.identifier,'MATLAB:pmaxsize')
                    obj.localizedError('daq:Session:tooManySamples');
                end
                rethrow(e)
            end
            
            % Throw any errors that occurred during callbacks.
            throwErrorOccurred();
            
            function throwErrorOccurred()                
                % If an error occurred, then allow the vendor to respond to
                % it
                if ~isempty(errorCapture)
                    obj.throwErrorOccurredHook(errorCapture);
                end
            end

            % Callback that captures data to the output parameters
            % (apparently, this cannot be inside the try/catch block)
            function queueResults(~, dataAvailableInfo)
                % Remove padded data
                if currentIndex > (obj.NumberOfScans * obj.TriggersPerRun)
                    return;
                end
                
                % Figure out where the data will go
                finalIndex = min(size(dataAvailableInfo.Data,1) + currentIndex - 1, double(obj.NumberOfScans * obj.TriggersPerRun));
                
                % Copy data and timestamps from the event record
                data(currentIndex:finalIndex,:) = dataAvailableInfo.Data(1:finalIndex-currentIndex+1, :);
                time(currentIndex:finalIndex) = dataAvailableInfo.TimeStamps(1:finalIndex-currentIndex+1);
                
                % Update the position of the next write
                currentIndex = finalIndex + 1;
                
                if isempty(triggerTime)
                    % Capture the trigger time if we have not already done
                    % so.
                    triggerTime = dataAvailableInfo.TriggerTime;
                end
            end
            
            % Callback that captures errors
            function captureError(~, errorOccurredInfo)
                errorCapture = errorOccurredInfo.Error;
            end
            
            function result = numberOfPulseWidthOrFreqCIChanPresent
                freqChannels = eval(....
                    ['obj.Channels.countChannelsOfType(''daq.',obj.Vendor.ID,'.CounterInputFrequencyChannel'')']);
                pwChannels = eval(...
                    ['obj.Channels.countChannelsOfType(''daq.',obj.Vendor.ID,'.CounterInputPulseWidthChannel'')']);
                result = freqChannels + pwChannels;
            end
        end
        
        function doStartBackground(obj)
            daq.Session.checkLicense();
            obj.validateChannels()
            
            if obj.TriggersPerRun > 1 && obj.IsContinuous ==  true
                obj.localizedError('daq:Session:noContinuousBackgroundStartWithMultipleTriggersPerRun');
            end
            
            if obj.Channels.countInputChannels() > 0 &&...
                    obj.DataAvailableListenerAdded == false
                % The user must provide a listener on the DataAvailable
                % event before starting a background acquisition  when the
                % session contains input channels.
                obj.localizedError('daq:Session:noListeners')
            end
            
            if obj.Channels.countOutputChannels() > 0 &&...
                    obj.IsContinuous &&...
                    obj.ScansQueued < obj.NotifyWhenScansQueuedBelow
                % The user must queue more data to the output buffer
                obj.localizedError('daq:Session:scansQueuedBelow', num2str(obj.NotifyWhenScansQueuedBelow))
            end
            
            obj.configureAcquisitionBuffersForStart()
            obj.startHardware()
        end
        
        function doWait(obj,timeout)
            % Validate timeout
            if ~isscalar(timeout) || ~isnumeric(timeout) || isnan(timeout) || timeout <= 0
                obj.localizedError('daq:Session:invalidTimeout')
            end
            if obj.IsContinuous && isinf(timeout)
                obj.localizedError('daq:Session:noInfWaitOnContinuous')
            end
            
            % Wait for up to timeout seconds for obj to reach IsRunning state.
            localTimer = tic;
            while obj.IsRunning == true &&...
                    (isinf(timeout) || toc(localTimer) < timeout)
                % We do DRAWNOW and PAUSE because it turns out that PAUSE
                % can be disabled by the user.  If that were to happen,
                % events will still be processed by DRAWNOW.
                drawnow();
                pause(0.1);
            end
            if obj.IsRunning == true
                %g1018855, g1013375: default behavior is to generate a
                %time-out error. However, if vendor can provide additional
                %information as to the cause of the timeout, they may
                %choose to do so
                obj.timeoutErrorHook();
            end
        end
        
        function doStop(obj,noWait)
            % Call the vendor implementation to start a hardware stop.
            % This does not mean that the hardware has stopped, just that
            % we've asked it to.  Vendor calls processHardwareStop() when
            % it has actually stopped.
            
            % g1137557 Must reset triggers remaining to 0 on a stop
            obj.TriggersRemaining = 0;
            
            obj.stopImpl();
            
            if noWait
                % noWait is an undocumented functionality that may be removed
                % in a future release.  When this optional parameter is set
                % true, the stop method will not wait for IsRunning to go to
                % false.  This functionality is used by the automated test
                % system to verify the state machine functionality.
                return
            end
            try
                obj.doWait(obj.StopTimeout)
            catch e
                if strcmp(e.identifier,'daq:Session:timeout')
                    % Recast error to a more appropriate one for timeout
                    obj.localizedError('daq:Session:stopDidNotComplete')
                end
                rethrow(e)
            end
        end
        
        function doQueueOutputData(obj,dataToOutput)
            % This only gets called if there are channels in the session,
            % and there is additional data queued to the hardware AFTER the
            % prepareHook() function is called.
            obj.errorOnInvalidOutputData(dataToOutput);
            
            % Call the vendor implementation to queue the data to hardware.
            % In case of multiple triggers, the same queued data is reused
            % by the session for the next trigger.
            obj.queueOutputDataImpl(dataToOutput);
            
            % G834043: This method gets called before (or during) a trigger
            % run. Only accumulate data for next trigger if session is not
            % running (i.e. do not accumulate data when running and queuing
            % in continuous mode)
            if ~obj.IsRunning
                obj.DataToOutputForNextTrigger = [obj.DataToOutputForNextTrigger;dataToOutput];
            end
            
            obj.updatePropertiesAfterQueuingData(dataToOutput);
        end
        
        function doResetCounters(obj)
            numberOfCounterChannels = obj.Channels.countCounterInputChannels();
            if numberOfCounterChannels == 0
                obj.localizedError('daq:Session:noCounterChannels')
            end
            
            % Call the vendor to reset counters
            obj.resetCountersImpl();
        end
        
        function [data,triggerTime] = doInputSingleScan(obj)
            daq.Session.checkLicense();
            isInputCacheValid = obj.IsInputCacheValid;
            
            if ~isInputCacheValid 
                inputCache = makeInputCache();
                obj.InputScanCache = inputCache;
            else
                inputCache = obj.InputScanCache;
            end
                
            if inputCache.NumInputChannels == 0
                obj.localizedError('daq:Session:noInputChannels')
            end
            
            if ~inputCache.OnDemandOperationsSupported
                obj.localizedError('daq:Session:onDemandOperationsDisabled')
            end
            
            % Call the vendor to get the data
            [data,triggerTime] = obj.inputSingleScanImpl();
            
            if ~isInputCacheValid
                obj.IsInputCacheValid = true;
            end
            
            if daq.internal.getOptions().FullDebug
                % Validate the format of the return data
                if size(data,2) ~= inputCache.NumInputChannels ||...
                        size(data,1) ~= 1 ||...
                        ~isscalar(triggerTime) || ~isnumeric(triggerTime)
                    obj.localizedError('daq:Session:invalidInputData')
                end
            end
            
            function cache = makeInputCache
                cache.NumInputChannels = obj.Channels.countInputChannels();
                cache.OnDemandOperationsSupported = all([obj.Channels.OnDemandOperationsSupported]);
            end
        end
        
        function doOutputSingleScan(obj, dataToOutput)
            daq.Session.checkLicense();
            isOutputCacheValid = obj.IsOutputCacheValid;

            if ~isOutputCacheValid 
                outputCache = makeOutputCache(obj.Channels);
                obj.OutputScanCache = outputCache;
            else
                outputCache = obj.OutputScanCache;
            end
            
            numberOfOutputChannels = outputCache.NumOutputChannels;
                   
            if numberOfOutputChannels == 0
                obj.localizedError('daq:Session:noOutputChannels')
            end
            
            % Verify all channels support on demand operations
            if ~outputCache.OnDemandOperationsSupported
                obj.localizedError('daq:Session:onDemandOperationsDisabled')
            end
            
            % Only accept regular arrays
            if iscell(dataToOutput)
                obj.localizedError('daq:Session:invalidDataFormat')
            end
            
            % Validate Data
            if ~ismatrix(dataToOutput) || ~all(all(isfinite(dataToOutput))) 
                obj.localizedError('daq:Session:invalidDataFormat')
            end
            
            if size(dataToOutput,2) ~= numberOfOutputChannels
                % The output data should have the same number of columns as
                % there are output channels
                obj.localizedError('daq:Session:incorrectColumnCount')
            end
            
            if size(dataToOutput,1) ~= 1
                % The output data should have only one row
                obj.localizedError('daq:Session:onlyOneRow')
            end
            
            % Validate Data
            dataToOutputCellArray = cell(1, numel(dataToOutput));

            aoChannelIndices = outputCache.AnalogOutputChannelIndices;
            doChannelIndices = outputCache.DigitalOutputChannelIndices;
            
            outputIndices = aoChannelIndices | doChannelIndices;
            
            ooIdx = cumsum(outputIndices);
            aoIdx = ooIdx(aoChannelIndices);
            doIdx = ooIdx(doChannelIndices);
            
            % Analog Output Data
            if ~isempty(aoIdx)
                aoData = dataToOutput(aoIdx);
                
                if ~isnumeric(aoData)
                    obj.localizedError('daq:Session:invalidDataFormat');
                end
                
                % G633205 Ensure that the data is not out of range.
                if any((aoData > outputCache.AnalogOutputRangeMaxima) | ...
                       (aoData < outputCache.AnalogOutputRangeMinima))
                    
                    errorIfScanOutOfRange(dataToOutput, aoChannelIndices, outputCache);
                end
                
                for idx = 1:numel(aoIdx)
                    dataToOutputCellArray{aoIdx(idx)} = dataToOutput(aoIdx(idx));
                end
            end
            
            % Digital Output Data
            if ~isempty(doIdx)
                dioData = dataToOutput(doIdx);
            
                if isnumeric(dioData)
                    % hasOnlyDigitalValues
                    if ~all(all(dioData == 0 | dioData == 1))
                        obj.localizedError('daq:Session:digitalChannelInvalidDataFormat');
                    end
                else
                    if ~islogical(dioData)
                        obj.localizedError('daq:Session:invalidDataFormat')
                    end
                end
                
                for idx = 1:numel(doIdx)
                    dataToOutput(doIdx(idx)) = double(dioData(idx));
                    dataToOutputCellArray{doIdx(idx)} = dataToOutput(doIdx(idx));
                end
            end
            
            obj.outputSingleScanImpl(dataToOutputCellArray);
            
            if ~isOutputCacheValid
                obj.IsOutputCacheValid = true;
            end            
            
            function errorIfScanOutOfRange(dataToOutput, channelIndices, cache)
                % Match up the dataToOutput with the Output channels (skip over
                % any interleaving InputChannels).
                dataCol = 1;
                
                numChannels = cache.NumChannels;
                rangeMinima = cache.AnalogOutputRangeMinima;
                rangeMaxima = cache.AnalogOutputRangeMaxima;
                ranges = cache.AnalogOutputRanges;
                
                for chanNum = 1:numChannels
                    % Only process AO/AudO/Fgen data
                    if ~channelIndices(chanNum)
                        continue;
                    end
                    
                    rangeMin = rangeMinima(dataCol);
                    rangeMax = rangeMaxima(dataCol);
                    
                    [small, large] = bounds(dataToOutput(:, dataCol));
                    
                    if (large > rangeMax || small < rangeMin)
                        obj.localizedError('daq:Channel:dataOutOfRange',...
                            num2str(chanNum), char(ranges(dataCol)) );
                    end
                    
                    dataCol = dataCol + 1;
                end
            end
            
            function cache = makeOutputCache(channels)
                cache.NumOutputChannels = channels.countOutputChannels();
                cache.OnDemandOperationsSupported = all([channels.OnDemandOperationsSupported]);
                
                nchannels = numel(channels);
                cache.NumChannels = nchannels;
                channelSubsystemTypes = [channels.SubsystemString];
                
                aoIndices = contains(channelSubsystemTypes, "AnalogOutput");
                dioIndices = contains(channelSubsystemTypes, "DigitalIO");
                doIndices = false(1, nchannels);
                
                for chIdx = 1:nchannels
                    if ~dioIndices(chIdx)
                        continue
                    end
                    
                    if string(channels(chIdx).Direction) == string(daq.Direction.Output)
                        doIndices(chIdx) = true;
                    end
                end
                
                if any(aoIndices)
                    ranges = [channels(aoIndices).Range];
                
                    cache.AnalogOutputRangeMaxima = [ranges.Max];
                    cache.AnalogOutputRangeMinima = [ranges.Min];
                    cache.AnalogOutputRanges = ranges;
                end                
                
                cache.AnalogOutputChannelIndices = aoIndices;
                cache.DigitalIOChannelIndices = dioIndices;
                cache.DigitalOutputChannelIndices = doIndices;                
            end            
        end
        
        function doRelease(obj,isExplicitCommandByUser)
            if ~isExplicitCommandByUser && obj.WarnOnImplicitRelease
                % If release is a side effect of another action, and the user
                % explicitly called prepare, then warn that a release occurred.
                obj.localizedWarning('daq:Session:implicitReleaseOccurredWarning')
            end
            % Clear the warning flag.  If they call prepare again,
            % explicitly, it'll be set true again.
            obj.WarnOnImplicitRelease = false;
            
            if obj.Channels.countOutputChannels() > 0
                % If there's output channels, the queued data has to be
                % flushed, as the vendor implementation has already
                % optimized for the queue.
                obj.flushOutputData(true);
            end

            % Call the appropriate template method to give the vendor the
            % chance to release resources associated with an operation

            if isExplicitCommandByUser && ~obj.IsReleaseInternal
                obj.releaseExplicitHook()
            else
                obj.releaseHook();
            end
            
            % cached values may only be used by a prepared session
            obj.clearSingleScanCache();
        end
    end
    
    % State-machine helper methods
    methods(Hidden, Sealed)
        function requeueOutputData(obj)
            obj.queueOutputDataImpl(obj.DataToOutputForNextTrigger);
        end
        
        function accumulateOutputData(obj,dataToOutput)
            % This only gets called if there are channels in the session,
            % and the prepareHook() function has not yet been called.
            obj.errorOnInvalidOutputData(dataToOutput);
            
            % Create or recreate the generation queue buffer if does not
            % yet exist, or if it is not configured for the number of
            % channels in the object.
            if isempty(obj.GenerationQueue)
                obj.GenerationQueue = daq.internal.ScanQueue(...
                    size(dataToOutput,2),...
                    size(dataToOutput,1),...
                    false);
            end
            % Put the data in the buffer
            obj.GenerationQueue.writeScansToQueue(...
                dataToOutput);
            
            % This method only gets called before the first trigger run.
            % Save data to be output for next trigger run.
            obj.DataToOutputForNextTrigger = [obj.DataToOutputForNextTrigger;dataToOutput];
            
            obj.updatePropertiesAfterQueuingData(dataToOutput);
        end
        
        function flushOutputData(obj,fireWarning)
            % Flushes the output buffer when the session configuration
            % changes
            if isempty(obj.GenerationQueue)
                % The data was sent to the vendor --
                % Call the vendor implementation to flush the output queue
                obj.flushOutputDataImpl();
            else
                % Delete the generation queue
                obj.GenerationQueue = [];
            end
            
            if obj.ScansQueued ~= 0 && fireWarning && obj.FireFlushWarning
                obj.localizedWarning('daq:Session:queuedDataHasBeenDeleted')
            end
            
            obj.ScansQueued = uint64(0);
            obj.ScansTransferred = uint64(0);
            obj.DataToOutputForNextTrigger = [];
            
            if obj.IsContinuous == false
                % Updates NumberOfScans to be ScansQueued when we are not
                % in continuous output mode.
                obj.ScanQueuingInProgress = true;
                obj.NumberOfScans = obj.ScansQueued;
                obj.ScanQueuingInProgress = false;
            end
        end
        
        function resetScanCounters(obj)
            % Reset the counter of scans output by the hardware.  Used by
            % the state machines when transitioning to new states.
            obj.ScansOutputByHardware = uint64(0);
            obj.ScansAcquired = uint64(0);
            obj.TotalScansAvailableNotified = uint64(0);
        end
        
        function configSampleClockTiming(obj)
            obj.configSampleClockTimingImpl();
        end        
        
        function mediator = getChannelMediator(obj,mediatorTag,mediatorClass,varargin)
            % A channel can register and use a mediator object to define
            % complex interactions between channels, without knowing how
            % many channels are involved.
            %
            % This is an implementation of the "Mediator" design pattern.
            % Channels are "colleagues" who interact in various ways defined
            % by mediator objects.
            
            if obj.ChannelMediators.isKey(mediatorTag)
                % Channel mediator with mediatorTag exists -- get it
                mediator = obj.ChannelMediators(mediatorTag);
            else
                % Channel mediator with mediatorTag does not exist -- create it
                % and add it to the map.
                mediator = feval(str2func(mediatorClass),varargin{:});
                if ~isa(mediator,'daq.internal.ChannelMediator')
                    obj.localizedError('daq:Session:invalidMediator')
                end
                obj.ChannelMediators(mediatorTag) = mediator;
            end
            % Increment the instance count on the mediator
            mediator.InstanceCount = mediator.InstanceCount + 1;
        end
        
        function releaseChannelMediator(obj,mediatorTag)
            % When a channel is removed, it should decrement the count on
            % the registered mediator.  When there are no channels uses a
            % mediator object, it is removed.
            %
            % This is an implementation of the "Mediator" design pattern.
            % Channels are "colleagues" who interact in various ways defined
            % by mediator objects.
            
            % Get mediator with mediatorTag exists
            try
                mediator = obj.ChannelMediators(mediatorTag);
            catch e
                if strcmp(e.identifier,'MATLAB:Containers:Map:NoKey')
                    obj.localizedError('daq:Session:unknownMediator')
                else
                    rethrow(e)
                end
            end
            
            % Decrement the instance count on the mediator
            mediator.InstanceCount = mediator.InstanceCount - 1;
            
            %If the instance count is 0, remove the mediator from the map
            %and delete it.
            if mediator.InstanceCount <= 0
                mediatorToDelete = obj.ChannelMediators(mediatorTag);
                obj.ChannelMediators.remove(mediatorTag);
                delete(mediatorToDelete)
            end
        end
        
        function startHardware(obj)
            % This is just by the Session state to start hardware when there are no multiple triggers.
            obj.startHardwareImpl();
        end
        
        function startHardwareBetweenTriggers(obj)
            obj.AcquisitionQueue.reset();
            % This is just by the Session state to start hardware when there are multiple triggers.
            obj.startHardwareBetweenTriggersImpl();
        end
    end     
    
    % Event-Handlers
    methods(Hidden, Sealed)
        function handleProcessAcquiredData(obj,triggerTime,timestamps,dataAcquired)
            if daq.internal.getOptions().FullDebug
                if size(dataAcquired,2) ~= obj.Channels.countInputChannels()
                    % The input data should have the same number of columns as
                    % there are input channels
                    obj.localizedError('daq:Session:invalidInputData')
                end
                if size(dataAcquired,1) ~= size(timestamps,1)
                    % Each row of the input data should have a matching row in
                    % the timestamps
                    obj.localizedError('daq:Session:invalidInputTimestamps')
                end
                if isscalar(triggerTime) ~= isnumeric(triggerTime)
                    % triggerTime should be a scalar numeric
                    obj.localizedError('daq:Session:invalidInputTriggerTime')
                end
            end
            
            % Capture the trigger time
            obj.TriggerTime = triggerTime;
            
            % Increase the total acquired data
            if obj.IsContinuous == true
                obj.ScansAcquired = obj.ScansAcquired + size(dataAcquired,1);
            else
                obj.ScansAcquired = min(obj.LastRunNumberOfScans, ...
                    obj.ScansAcquired + size(dataAcquired,1));
            end
            
            % Store the data in the acquisition queue
            obj.AcquisitionQueue.write([dataAcquired,timestamps])
            
            % Check to see if the DataAvailable event should be fired
            obj.fireDataAvailableIfNeeded(false);
        end
        
        function emptyAcquisitionQueue(obj)
            % Called by the state machine to force the last scans in the
            % acquisition buffer out
            obj.fireDataAvailableIfNeeded(true);
        end
        
        function handleProcessHardwareTrigger(obj,varargin)
            % Currently, hardware triggers are not implemented.
            obj.throwNotImplementedError();
        end
        
        function handleProcessOutputEvent(obj,totalScansGenerated)
            obj.ScansOutputByHardware = uint64(min(obj.LastRunNumberOfScans, totalScansGenerated));
            obj.ScansQueued = uint64(max(0,double(obj.ScansTransferred) - totalScansGenerated));
            
            % Check to see if the DataRequired event should be fired
            obj.fireDataRequiredIfNeeded();
        end
        
        function handleProcessHardwareStop(obj,errorException)
            % This handles both natural and error condition stops reported
            % by the hardware.  If errorException has an MException in it,
            % it is an error stop, and the ErrorOccurred event will be
            % fired
            if ~isempty(errorException)
                if ~isa(errorException,'MException')
                    obj.localizedError('daq:Session:invalidError')
                end
                notify(obj,'ErrorOccurred',...
                    daq.ErrorOccurredInfo(errorException))
            end
        end        
    end    
    
    % Hidden Sealed methods, so that they don't show up in methods()
    methods(Hidden, Sealed)
        function disp(obj,varargin)
            %disp display session information
            
            % In some contexts, such as publishing, you cannot use
            % hyperlinks.  If hotlinks is true, then you can.
            hotlinks = feature('hotlinks');
            
            % G757030: To fix Properties' hotlink error (Undefined function or
            % variable 'obj'.)
            if nargin > 1
                inputName = varargin{1};
            else
                inputName = inputname(1);
            end
            
            if nargin > 2
                hotlinks = varargin{2};
            end
            
            if any(~isvalid(obj)) || any(isempty(obj))
                % Invalid or empty object: use default behavior of handle class
                obj.disp@handle
                return
            end
            
            if numel(obj) == 1
                % Single object -- do detailed display
                
                % Title
                obj.localized_fprintf('daq:Session:dispTitle',obj.Vendor.FullName);
                
                % Delegate detailed display to the state objects.
                obj.InternalState.dispSession();
                
                syncText = obj.SyncManager.getSessionConnectionSummaryText(hotlinks,inputName);
                if ~isempty(syncText)
                    fprintf('\n')
                    fprintf(obj.indentText(syncText,...
                        daq.internal.BaseClass.StandardIndent));
                    fprintf('\n')
                    fprintf('\n')
                end
                
                % Display the channel table, indented 3 spaces
                fprintf(obj.indentText(obj.Channels.getDisplayText(),...
                    daq.internal.BaseClass.StandardIndent));
                
                % Check to see if the Vendor implementation has defined
                % additional information to append to the display
                suffixText = getSingleDispSuffixHook(obj);
                if ~isempty(suffixText)
                    fprintf('\n')
                    fprintf(suffixText);
                end
            else
                % It's a vector of objects:  Show as table
                obj.localized_fprintf('daq:Session:dispTableHeader')
                fprintf('\n');
                table = internal.DispTable();
                table.Indent = daq.internal.BaseClass.StandardIndent;
                table.addColumn(obj.getLocalizedText('daq:Session:dispTableIndexColumn'));
                table.addColumn(obj.getLocalizedText('daq:Session:dispTableVendorColumn'));
                table.addColumn(obj.getLocalizedText('daq:Session:dispTableNumDevicesColumn'));
                table.addColumn(obj.getLocalizedText('daq:Session:dispTableNumChannelsColumn'));
                table.addColumn(obj.getLocalizedText('daq:Session:dispTableDurationColumn'));
                table.addColumn(obj.getLocalizedText('daq:Session:dispTableRateColumn'));
                for iObj=1:numel(obj)
                    % Count the unique device IDs in the session
                    if isempty(obj(iObj).Channels)
                        numDevices = 0;
                    else
                        devices = [obj(iObj).Channels.Device];
                        numDevices = numel(unique({devices.ID}));
                    end
                    table.addRow(iObj,...
                        obj(iObj).Vendor.ID,...
                        numDevices,...
                        numel(obj(iObj).Channels),...
                        obj(iObj).DurationInSeconds,...
                        obj(iObj).Rate);
                end
                table.disp
            end
            fprintf('\n');
            
            
            obj.dispFooter(class(obj),inputName,hotlinks);
            
        end
        
        function dispSession(obj)
            % Delegate detailed display to the state objects.
            obj.InternalState.dispSession();
        end
    end 
    
    % Cache
    methods (Hidden)
        function clearSingleScanCache(obj)
            % Clear flags indicating whether variables cached for
            % input/output single-scans are still valid
            obj.IsInputCacheValid = false;
            obj.IsOutputCacheValid = false;
            
            obj.InputScanCache = struct([]);
            obj.OutputScanCache = struct([]);
            
            obj.clearSingleScanCacheHook();
        end
    end

    methods(Static, Hidden)
        function checkLicense()
            matlab.internal.licensing.checkoutProductLicense('DA');
        end
    end
    
    %% -- Protected and private members of the class --  
    
    % Hidden read only properties that can be modified by subclasses
    properties(Hidden, SetAccess = protected)
        %The limits on the rate of the operation, given its current
        %configuration
        RateLimitInfo
    end
    
    % Protected read only properties for use by a subclass
    properties(GetAccess = protected, SetAccess = private)
        % Contains the name of the current state of the Session object
        InternalStateName
    end
    
    % Protected constants for use by subclasses
    properties(Constant, GetAccess = protected)
        % The maximum number of times per second we'll accept before we
        % warn
        WarnIfEventsPerSecondExceeds = 20;
    end

    % Function-Generator methods
    methods(Access = {?daq.FunctionGeneratorChannel, ?daq.Session})
        function validatedRate = validateFunctionGeneratorFrequency(obj, frequency)
            validatedRate = obj.validateFunctionGeneratorFrequencyImpl(frequency);
        end
    end

    % Require implementation by a subclass
    methods(Access = protected)
        % These would normally be Abstract, but in order to address
        % G631826, which asks for a better error message when a user
        % attempts to instantiate a daq.Session, it is concrete.
        
        % createChannelImpl is implemented by the vendor to validate that
        % the requested channel can be created, and to create and return an object of
        % type daq.Channel conforming to the parameters passed. All
        % parameters will be pre-validated and will always be passed in
        % (other than the varargins)
        function newChannel = createChannelImpl(obj,...
                subsystem,...       % A daq.internal.SubsystemType defining the type of the subsystem to create a channel for on the device
                deviceInfo,...      % A daq.DeviceInfo object of the device that the channel exists on
                channelID,...       % A cell array of strings or numeric vector containing the IDs of the channels to create
                measurementType,... % A string containing the specialized measurement to be used, such as 'Voltage'.
                varargin...           % Any additional parameters passed by the user, to be interpreted by the vendor implementation
                )                       %#ok<INUSD,STOUT>
        end
        
        function newTriggerConn = createTriggerConnImpl(obj,...
                src,...
                dst,...
                type ...
                ) %#ok<INUSD,STOUT>
        end
        
        function newTriggerConn = createClockConnImpl(obj,...
                src,...
                dst,...
                type ...
                ) %#ok<INUSD,STOUT>
        end
        
        % startHardwareImpl is implemented by the vendor to start the
        % hardware.
        function startHardwareImpl(obj) %#ok<MANU>
        end
        
        % startHardwareImpl is implemented by the vendor to start the
        % hardware.
        function startHardwareBetweenTriggersImpl(obj) %#ok<MANU>
        end
        
        % stopImpl is implemented by the vendor to request a
        % hardware stop.  It is expected that the vendor will call
        % processHardwareStop() when the stop actually occurs.
        %
        % It is OK to call processHardwareStop() from within stopImpl, or
        % at a later time if the stop requires an asynchronous action off
        % the MATLAB thread (which it usually does)
        function stopImpl(obj) %#ok<MANU>
        end
        
        % queueOutputDataImpl is implemented by the vendor to handle data
        % to be queued to the hardware. All parameters will be pre-validated
        % and will always be passed in.
        function queueOutputDataImpl(obj,...
                dataToOutput...   % An mxn array of doubles where m is the number of scans, and n is the number of output channels
                )                       %#ok<INUSD>
        end
        
        % configSampleClockTimingImpl is implemented by the vendor to
        % reconfigure sample clock timing if needed. This is needed to
        % handle changing number of scans queued between operations
        function configSampleClockTimingImpl(obj, ...
                scansQueued...      % Total number of scans queued before start
                )                       %#ok<INUSD>
        end
        
        % flushOutputDataImpl is implemented by the vendor to delete any
        % data previously queued for output by the hardware.
        function flushOutputDataImpl(obj) %#ok<MANU>
        end
        
        % resetCountersImpl is implemented by the vendor to reset input
        % counters
        function resetCountersImpl(obj) %#ok<MANU>
        end
        
        % inputSingleScanImpl is implemented by the vendor to acquire a
        % single scan of the input channels and return them.
        %
        % data: An 1xn array of doubles where n is the number of input channels
        function [data,triggerTime] = inputSingleScanImpl(obj) %#ok<MANU,STOUT>
        end
        
        % outputSingleScanImpl is implemented by the vendor to generate a
        % single scan of the output channels. All parameters will be pre-validated
        % and will always be passed in.
        function outputSingleScanImpl(obj,...
                dataToOutput...   % An 1xn array of doubles where n is the number of output channels
                )                       %#ok<INUSD>
        end
        
        
        % validateFunctionGeneratorGenerationRateImpl is implemented by the
        % vendor to ensure that the session reconcile the choices made by 
        function validatedRate = validateFunctionGeneratorFrequencyImpl(obj, frequency) %#ok<INUSL>
            validatedRate = frequency;
        end       
    end
    
    % Optional implementation by a subclass
    methods(Access = protected)
        function suffixText = getSingleDispSuffixHook(obj) %#ok<MANU>
            %getSingleDispSuffixImpl Subclasses override to customize disp
            %suffixText = getSingleDispSuffixImpl() Optional override by
            %Session subclasses to allow them to append custom
            %information to the disp of a single Session object.
            
            suffixText = '';
        end
        
        function adjustedValue = adjustNewRateHook(obj)
            % adjustNewRateHook Adjust the rate requested by user
            % Provides the vendor the opportunity to adjust the rate of a
            % session to reflect hardware limitations, such as rate clock
            % dividers.
            %
            % NEWRATE = adjustNewRateHook(REQUESTEDRATE) is called with the
            % double REQUESTEDRATE from the user. The function returns the
            % double NEWRATE, which may be adjusted to reflect hardware
            % limitations.
            %
            % adjustNewRateHook is called after RateLimit checks have been
            % done.  NEWRATE will be adjusted to fall within RateLimit.
            % Note that sessionPropertyBeingChanged will still be
            % called regarding the change to Rate after this.
            %
            %Default implementation is to make no change.
            adjustedValue = obj.Rate;
        end
        
        function updateRateLimitInfoHook(obj)
            % updateRateLimitInfoHook Adjust the RateLimit
            % Provides the vendor the opportunity to adjust the
            % RateLimitInfo of a session to reflect channel adds and
            % deletes.
            %
            % updateRateLimitInfoHook() is called after channels are added
            % or removed from a session.  The vendor implementation must
            % directly set the RateLimitInfo property if it wishes to
            % change the current setting
            %
            % Note that sessionPropertyBeingChanged will still be
            % called regarding the change to RateLimitInfo after this.
            %
            %Default implementation is to select a rate limit that is the
            %intersection of the rate limits for each channel.  Vendor can
            %override to provide their own max and min rate given the
            %current hardware configuration.  If there are no channels, the
            %RateLimitInfo is set to daq.internal.ParameterLimit.empty
            
            % If there are no channels, set obj.RateLimitInfo to empty
            if isempty(obj.Channels)
                obj.RateLimitInfo = daq.internal.ParameterLimit.empty;
                return
            end
            
            % Find the intersection of the RateLimits of the subsystems for
            % the channels
            subsystems = obj.Channels.getSubsystem();
            ratelimits = [subsystems.RateLimitInfo];
            % Find the largest minimum
            newMin = max([ratelimits.Min]);
            % Find the smallest maximum
            newMax = min([ratelimits.Max]);
            
            obj.RateLimitInfo = daq.internal.ParameterLimit(newMin,newMax);
        end
        
        function removeChannelHook(obj,index) %#ok<INUSD>
            % removeChannelHook React to the removal of a channel.
            %
            % Provides the vendor the opportunity to change their
            % configuration when a channel is removed.  Note that
            % releaseHook() will be called before this if needed.
            %
            % removeChannelHook(INDEX) is called before channels are
            % removed from a session.  The vendor implementation may
            % throw an error to prevent removal of a channel.  INDEX is the
            % index of the channel to be removed in the Channels property.
            %
            %Default implementation is to do nothing.
        end
        
        function removeConnectionHook(obj,index) %#ok<INUSD>
            % removeConnectionHook React to the removal of a connection.
            %
            % Provides the vendor the opportunity to change their
            % configuration when a connection is removed.  Note that
            % releaseHook() will be called before this if needed.
            %
            % removeConnectionHook(INDEX) is called before channels are
            % removed from a session.  The vendor implementation may
            % throw an error to prevent removal of a channel.  INDEX is the
            % index of the connection to be removed in the Connections property.
            %
            %Default implementation is to do nothing.
        end
        
        % This method should be overridden by the vendor adaptor if special
        % channel handling is required, otherwise, a cell array of channels
        % is returned.
        function [result] = parseChannelsHook(obj, subsystem, channelID) %#ok<INUSL>
            result = daq.Channel.parseChannelsHook(channelID);
        end
        
        function channelsChangedHook(obj) %#ok<MANU>
            % channelsChangedHook Notify the vendor if a channel was added
            % or removed from the session.Channels property.
            %
            %Default implementation is to do nothing.
        end
        
        function prepareHook(obj) %#ok<MANU>
            % prepareHook Set up to reduce latency of impending startImpl
            %
            % Provides the vendor the opportunity to preallocate hardware
            % in advance of a call to startImpl, in order to reduce latency
            % associated with start.
            %
            %Default implementation is to do nothing.
        end
        
        function releaseHook(obj) %#ok<MANU>
            % releaseHook Release resources allocated during prepareHook
            %
            % Provides the vendor the opportunity to release hardware
            % allocated by prepareHook, in order to reduce latency
            % associated with start. Vendor should call this method if
            % release was called as a side-effect of another method
            %
            %Default implementation is to do nothing.
        end
        
        % g1025920        
        function releaseExplicitHook(obj) %#ok<MANU>
            % releaseExplicitHook Release resources allocated during
            % prepareHook
            %
            % Provides the vendor the opportunity to release hardware
            % allocated by prepareHook, in order to reduce latency
            % associated with start. Vendor should call this method if
            % release was called explicitly by the user            
            %
            %Default implementation is to do nothing.
        end        
        
        function sessionPropertyBeingChangedHook(obj,propertyName,newValue) %#ok<INUSD>
            % sessionPropertyBeingChangedHook React to change in session property.
            %
            % Provides the vendor the opportunity to react to changes in
            % session properties.  Note that releaseHook() will be called
            % before this if needed.
            %
            % sessionPropertyBeingChangedHook(PROPERTYNAME,NEWVALUE)
            % is called before property changes occur.  The vendor
            % implementation may throw an error to prevent the change, or
            % update their corresponding hardware session, if appropriate.
            % PROPERTYNAME is the name of the property to change, and
            % NEWVALUE is the new value the property will have if this
            % function returns normally.
            %
            %Default implementation is to do nothing.
        end
        
        function [syncObjectClassName] = getSyncManagerObjectClassNameHook(obj) %#ok<MANU>
            % getSyncObjectClassNameHook Specify the name of the class that implements the vendor specific daq.Sync specialization.
            %
            % Provides the vendor the opportunity to provide the name of
            % the class to use when the Sync object is instantiated.
            %
            % [syncObjectClassName] = getSyncObjectClassNameHook() is
            % called when the session is created.
            %
            %Default implementation is to return
            %'daq.internal.SyncNotImplemented', which results all calls to
            %the Sync object giving an error.
            syncObjectClassName = 'daq.internal.SyncManagerNotImplemented';
        end
        
        function timeoutErrorHook(obj)
            % timeoutErrorHook React to a timeout in a foreground operation
            %
            % Provides the vendor with the opportunity to provide
            % additional information as to the cause of a timeout event.
            obj.localizedError('daq:Session:timeout')
        end
        
        function throwErrorOccurredHook(obj, errorCapture) %#ok<INUSL>
            % throwErrorOccurredHook React to errors that occurred during
            % callbacks in a foreground operation
            %
            % Provides the vendor with the opportunity to react to
            % ErrorOccurred events that were generated by a foreground
            % operation.
            throw(errorCapture);
        end
        
        function clearSingleScanCacheHook(obj) %#ok<MANU>
            % clearSingleScanCacheHook Allow vendor to clear
            % vendor-specific cached variables required to speed up
            % single-scan operations
        end
    end
    
    % No implementation by a subclass; for use by subclass
    methods (Sealed, Access = protected)
        function processAcquiredData(obj,triggerTime,timestamps,dataAcquired)
            % processAcquiredData Transfer acquired data to user.
            %
            % Vendor calls this function when there is new acquired data
            % to be transferred to the user.  This function should only be
            % called after StartImpl has been called.  It can be called an
            % arbitrary number of times before processHardwareStop is
            % called, and must be called once after processHardwareStop
            % with the last data acquired.  If there is no data remaining,
            % calling with 0 rows of data is OK.
            %
            % processAcquiredData(TRIGGERTIME,TIMESTAMPS,DATAACQUIRED)
            % TRIGGERTIME is a MATLAB serial date time stamp representing
            % timestamp of 0. TIMESTAMPS is a mx1 array of timestamps
            % relative to the time the operation was triggered, where m is
            % the number of scans acquired. DATA is an mxn array of doubles
            % where m is the number of scans acquired, and n is the number
            % of input channels in the session.
            
            % Delegate to the state objects. If it is a valid operation, it will
            % come back as handleProcessAcquiredData
            if isvalid(obj.InternalState)
                obj.InternalState.processAcquiredData(triggerTime,timestamps,dataAcquired);
            end
        end
        
        function processHardwareTrigger(obj,varargin)
            % processHardwareTrigger Notify Data Acquisition Toolbox of hardware trigger.
            %
            % Vendor calls this function when a hardware trigger occurs.
            %
            % processHardwareTrigger is not yet implemented.
            
            % Delegate to the state objects. If it is a valid operation, it will
            % come back as handleProcessHardwareTrigger
            obj.InternalState.processHardwareTrigger(varargin{:});
        end
        
        function processOutputEvent(obj,totalScansGenerated)
            % processOutputEvent Notify Data Acquisition Toolbox of analog output status.
            %
            % Vendor calls this function to notify the toolbox that data
            % has been output.  This function should only be called after
            % StartImpl has been called.  It can be called an arbitrary
            % number of times before processHardwareStop is called.
            %
            % processOutputEvent(TOTALSCANSGENERATED)
            % TOTALSCANSGENERATED is a double representing the total
            % number of scans transferred to the hardware during the run.
            
            % Delegate to the state objects. If it is a valid operation, it will
            % come back as handleProcessOutputEvent
            if isvalid(obj.InternalState)
                obj.InternalState.processOutputEvent(totalScansGenerated);
            end            
        end
        
        function processHardwareStop(obj,errorException)
            % processHardwareStop Notify Data Acquisition Toolbox of hardware stop.
            %
            % Vendor calls this function to notify the toolbox that the
            % hardware has stopped, either naturally, as a result of a
            % stopImpl, or because of an error.
            %
            % processHardwareStop() indicates that the hardware stopped
            % with no errors.
            %
            % processHardwareStop(ERROREXCEPTION) indicates that the
            % hardware stopped due to an error, and that the user should be
            % notified via an daq.Session.ErrorOccurred event.
            % ERROREXCEPTION is an object of class MException containing
            % information about the error.
            
            % Delegate to the state objects. If it is a valid operation, it will
            % come back as handleProcessHardwareStop
            if nargin < 2
                errorException = [];
            end
            
            % g1725413 - when a reset occurs while the hardware is running,
            % the internal state might become invalid; ensure that the
            % session still reaches a known state
            if isvalid(obj.InternalState)
                obj.InternalState.processHardwareStop(errorException);
            else
                obj.IsLogging = false;
                obj.IsRunning = false;
                obj.IsDone = true;
            end
        end
        
        function sessionPropertyBeingChanged(obj,propertyName,newValue)
            % sessionPropertyBeingChanged Notify Data Acquisition Toolbox of session property change.
            %
            % Vendor calls this function to notify the toolbox that a
            % vendor specific property on the vendor specialization of the
            % daq.Session class has changed.  The vendor can use this to
            % ensure that property changes are legal under the current
            % state (most property changes are not allowed while running).
            % The caller should accommodate sessionPropertyBeingChanged
            % throwing an exception.
            %
            % sessionPropertyBeingChanged(PROPERTYNAME,NEWVALUE)
            % indicates that the property with the name PROPERTYNAME is
            % about to change to NEWVALUE.
            %
            % Note that this will cause sessionPropertyBeingChangedHook() to be
            % called as a side effect.  It is recommended that this be used
            % to update the session, as future versions of the toolbox may
            % use this functionality to implement load/save or other
            % features.
            
            % Check if this is legal
            obj.errorIfParameterChangeNotOK()
            
            % G1870366: Setting IsContinuous to true should error if
            % on-demand channels are present in the session                       
            switch propertyName
                case 'IsContinuous' 
                    if newValue && ~isempty(obj.RateLimit) && obj.RateLimit(2) == 0
                        obj.localizedError('daq:Session:isContinuousForOnDemand');
                    end                    
            end
            % Call the vendor implementation to implement the property
            % change
            obj.sessionPropertyBeingChangedHook(propertyName,newValue)
        end
        
        function throwUnknownChannelIDError(obj, device, unknownChannelID, validChannelIDs)
            % Throw error on behalf of vendor when channelID is unknown
            % Vendor implementations call this from createChannelImpl to
            % indicate that the requested channel is unknown.
            %
            % throwUnknownChannelIDError(UNKNOWNCHANNELID,VALIDCHANNELIDS)
            % UNKNOWNCHANNELID is the channelID that the user passed in as
            % a string. VALIDCHANNELIDS is a cell array of valid channelID
            % strings.
            
            if ~isa(device,'daq.DeviceInfo') || ...
               ~daq.internal.isScalarStringOrCharVector(unknownChannelID) || ...
               (~iscellstr(validChannelIDs) && ~isstring(validChannelIDs))
                % Really an internal error, as the vendor did not call the
                % function correctly, so show the error with no info (which
                % is still useful)
                obj.localizedError('daq:Session:unknownChannelID','','','')
            end
            
            unknownChannelID = char(unknownChannelID);
            validChannelIDs = cellstr(validChannelIDs);
            
            validChannelIDs = obj.renderCellArrayOfStringsToString(validChannelIDs,''', ''');
            obj.localizedError('daq:Session:unknownChannelID', ...
                               device.ID, ...
                               unknownChannelID, ...
                               validChannelIDs)
        end
    end

    % Superclass methods requiring implementation by this class 
    methods (Sealed, Access = protected)
        function resetImpl(obj)
            %resetImpl Handle daq.reset (which is usually delete)
            if isvalid(obj)
                delete(obj)
            end
        end
    end       
    
    properties (Hidden)
        % The maximum percentage of RAM available for streaming operations
        PercentMaximumMemoryForStreaming {mustBeGreaterThanOrEqual(PercentMaximumMemoryForStreaming,0) ...
            mustBeLessThanOrEqual(PercentMaximumMemoryForStreaming,100)}
    end
    
    methods (Access = {?daq.ni.AsyncIOInputChannel, ...
                       ?daq.ni.AsyncIOOutputChannel, ...
                       ?tStreamLimits,...
                       ?daq.Session})
                   
        function inputStreamLimit = getInputStreamLimit(obj)
            switch(computer)
                case 'PCWIN64'
                    fillFactor = obj.PercentMaximumMemoryForStreaming/100;
                    inputStreamLimit = getWindowsStreamLimit(fillFactor);
                case {'MACI64', 'GLNXA64'}
                    inputStreamLimit = inf;
            end
            
            function limit = getWindowsStreamLimit(fillFactor)
                userview = memory;
                
                % Fraction of usable RAM available for streaming
                limit = floor(fillFactor * userview.MemAvailableAllArrays);
            end
        end
        
        function outputStreamLimit = getOutputStreamLimit(obj) %#ok<MANU>
            outputStreamLimit = inf;
        end
        
    end
    % Cache Validation
    properties (GetAccess = protected, SetAccess = private)
        % False if the input cache has not been set. May be set to true
        % after inputSingleScan has finished calling inputSingleScanImpl
        IsInputCacheValid (1, 1) logical
        
        % False if the output cache has not been set. May be set to true
        % after outputSingleScan has finished calling outputSingleScanImpl
        IsOutputCacheValid (1, 1) logical
        
        InputScanCache (1, :) struct = struct([])
        OutputScanCache (1, :) struct = struct([])
    end
        
    % Private properties
    properties (GetAccess = private, SetAccess = private)
        
        % Internal property that suppresses set.* functions during
        % initialization
        InitializationInProgress
        
        % Internal property that handle changes in
        % Rate/Duration/NumberOfScans public settings
        RateDurationNumScanChangeInProgress
        
        % Internal property that handle changes in
        % NotifyWhenDataAvailableExceeds and NotifyWhenScansQueuedBelow
        % public settings
        WaterMarkChangeInProgress
        
        % Internal property that allow updates to NumberOfScans despite
        % there being output channels in the session
        ScanQueuingInProgress
        
        % Internal property that allow updates to Rate
        RateChangeInProgress
        
        % When true, a DataRequired event has been fired, but the user has
        % not yet called queueOutputData.  This blocks additional firings
        % of the event
        IsWaitingForQueueOutputData
        
        % The initial trigger time captured from first call to
        % handleProcessAcquiredData
        TriggerTime
        
        % The queue containing acquired data and timestamps
        AcquisitionQueue
        
        % The queue containing data to output that hasn't been transferred
        % to the vendor yet
        GenerationQueue
        
        % Contains the current state of the Session object
        InternalState
        
        % A map of all the possible states of the Session
        InternalStateMap
        
        % When true, indicates that the user added a DataAvailable listener
        % to the Session object
        DataAvailableListenerAdded
        
        % When true, indicates that the user added a DataRequired listener
        % to the Session object
        DataRequiredListenerAdded
        
        % A map of mediator objects that channels can access to share information
        % between them.  This is an implementation of the "Mediator" design
        % pattern.  Channels are "colleagues" who interact in various ways
        % defined by mediator objects.
        ChannelMediators
        
        % If true, prepare() was explicitly called by the user.  In that
        % case, we will warn when a release happens as a side effect of
        % their actions
        WarnOnImplicitRelease
        
        % If true, release was internally (but explicitly) called by the
        % session. This permits the session to call the appropriate release
        % hook method.
        IsReleaseInternal        
        
        % Running total of the number of scans for which a DataAvailable
        % event was fired per operation. Used to break out of the notify
        % loop once we've notified for as many scans are requested.
        TotalScansAvailableNotified
        
        % G1870896: Set the initial rate specified by the vendor. Used to 
        % reset the rate while moving from StateOnDemand to StateNoChannel
        InitialRate
    end
    
    properties (GetAccess = {?daq.Session, ?daq.interfaces.DataAcquisition}, ...
                SetAccess = private)

        % Cache the data to output in case of multiple triggers.
        DataToOutputForNextTrigger
    end

    %% Internal constants
    
    properties(Constant, GetAccess = private)
        % When rate is set, the value that is selected is not always the
        % same as the one requested.  When the selected rate is more than
        % X percent different from the requested, fire a warning.
        WarnOnRateVariancePercentage = 1;
        
        % The maximum time in seconds to wait for IsRunning to go to false
        % after a stop
        StopTimeout = 5;
        
        % The percentage of the rate that is used by
        % NotifyWhenDataAvailableExceeds automatic set point
        NotifyWhenDataAvailableExceedsAutoPercentage = 0.1;
        
        % The percentage of the rate that is used by
        % NotifyWhenScansQueuedBelow automatic set point
        NotifyWhenScansQueuedBelowAutoPercentage = 0.5;
        
        % The minimum number of scans allowed.  This is 2 because there has
        % to be at least 2 scans to do a clocked output.
        MinimumNumberOfScans = uint64(2);
    end
    
    %% Properties accessible by the state machine 
    properties (Access = {?daq.Session, ?daq.internal.StateSession})
        % Cache the NumberOfScans parameter, so it can be restored when
        % IsContinuous is set to false.
        NumberOfScansCache
        
        % Cache the DurationInSeconds parameter, so it can be restored when
        % IsContinuous is set to false.
        DurationInSecondsCache
        
        % When true, IsDurationPreferred indicates that the most recent
        % successful USER operation was to set a Duration value.
        
        % Made hidden read-only to allow StateSession to use this property
        % for dispSession method.
        IsDurationPreferred
    end
    
    methods (Access = {?daq.Session, ?daq.internal.StateSession})
        function setRateToInitialRate(obj)
            if ~isempty(obj.RateLimitInfo)
                % Limit initialRate to RateLimitInfo
                obj.InitialRate = max(obj.InitialRate,obj.RateLimitInfo.Min);
                obj.InitialRate = min(obj.InitialRate,obj.RateLimitInfo.Max);
            end
            
            obj.Rate = obj.InitialRate;
        end
    end
    
    properties(Hidden, SetAccess = protected)
        % The percentage longer than duration that startForeground will
        % use for a timeout.  This is in addition to
        % StartForegroundTimeoutAdditional
        StartForegroundTimeoutPercentage = 1.1;
        
        % The number of seconds longer than duration that startForeground will
        % use for a timeout. This is in addition to
        % StartForegroundTimeoutPercentage
        StartForegroundTimeoutAdditional = 1;
    end
    
    %% Private methods
    methods(Access = private)
        function result = dispForNoOutputArgument(obj) %#ok<MANU>
                showHotLinks = feature('hotlinks'); %#ok<NASGU>

                % g941038: do not display a link for invalid objects
                result = evalc('disp(obj,[],showHotLinks)');
                % g1484166 - remove final newlines
                result = char(strip(string(result), 'right'));
        end
        
        function createInternalStateMap(obj)
            % Create the internal state map
            obj.InternalStateMap = containers.Map();
            addState('Initializing')
            addState('NoChannels')
            addState('NeedOutputData')
            addState('NeedOutputDataAndPrepared')
            addState('ReadyToStart')
            addState('ReadyToStartAndPrepared')
            addState('OnDemandOnly')
            addState('WaitingForHardwareTrigger')
            addState('HardwareRunning')
            addState('HardwareStopInProgress')
            addState('AcquiredDataWaiting')
            
            function addState(stateName)
                % Dynamically generate the names of the classes to
                % instantiate from the class name
                obj.InternalStateMap(stateName) =...
                    feval(str2func(['daq.internal.State' stateName]),obj);
            end
            
        end
        
        function result = isCurrentState(obj,expectedState)
            % Check if we're in the expected state
            result = strcmp(['daq.internal.State' expectedState],...
                class(obj.InternalState));
        end
        
        function validateChannels(obj)
            % Try to access each of the devices associated with each
            % channel to ensure they are still present
            for iChannel = 1:numel(obj.Channels)
                if isempty(obj.Channels(iChannel).Device)
                    obj.localizedError('daq:Session:deviceRemoved',num2str(iChannel))
                end
            end
        end
        
        function configureAcquisitionBuffersForStart(obj)
            % Clear the initial trigger time
            obj.TriggerTime = [];
            obj.AcquisitionQueue = matlabshared.asyncio.buffer.Buffer();
        end
        
        function updateNotifyWhenDataAvailableExceedsIfNeeded(obj)
            % Calculate the NotifyWhenDataAvailableExceeds value
            if obj.IsNotifyWhenDataAvailableExceedsAuto == true
                obj.WaterMarkChangeInProgress = true;
                % Always set NotifyWhenDataAvailableExceeds to 10% of
                % the Rate See g799820
                obj.NotifyWhenDataAvailableExceeds = uint64(ceil(obj.Rate * obj.NotifyWhenDataAvailableExceedsAutoPercentage));
                if obj.NumberOfScans ~= 0
                    obj.NotifyWhenDataAvailableExceeds = min(...
                        obj.NotifyWhenDataAvailableExceeds,...
                        obj.NumberOfScans);
                end
                obj.WaterMarkChangeInProgress = false;
            end
        end
        
        function updateNotifyWhenScansQueuedBelowIfNeeded(obj)
            % Calculate the NotifyWhenScansQueuedBelow value
            if obj.IsNotifyWhenScansQueuedBelowAuto == true
                % The NotifyWhenScansQueuedBelow is set to 50% of
                % the Rate
                obj.WaterMarkChangeInProgress = true;
                obj.NotifyWhenScansQueuedBelow = uint64(ceil(obj.Rate * ...
                    obj.NotifyWhenScansQueuedBelowAutoPercentage));
                obj.WaterMarkChangeInProgress = false;
            end
        end
        
        function fireDataRequiredIfNeeded(obj)
            if obj.IsContinuous == false ||...
                    obj.IsRunning == false ||...
                    obj.ScansQueued >= obj.NotifyWhenScansQueuedBelow ||...
                    obj.IsWaitingForQueueOutputData
                % Conditions to fire are not met.  It has to be a
                % continuous session and the scans queued need to be below
                % the low water mark
                % In addition, if we've fired the event in the past, and
                % the user has not called queueOutputData yet, then don't
                % fire it again
                return
            end
            
            % Fire the event and block future attempts until
            % queueOutputData is called
            obj.IsWaitingForQueueOutputData = true;
            notify(obj,'DataRequired')
        end
        
        function fireDataAvailableIfNeeded(obj,emptyAcquisitionQueue)
            % Repeatedly fire notifications until there is less than
            % NotifyWhenDataAvailableExceeds scans queued.  If the
            % emptyAcquisitionQueue flag is set, fire one last time to empty
            % the queue of any leftovers
            
            % If there's no data in the queue, exit
            numElementsAvailable = obj.AcquisitionQueue.NumElementsAvailable;
            
            if numElementsAvailable == 0
                return
            end

            notifySize = obj.NotifyWhenDataAvailableExceeds;
            
            % g1927019: don't issue partial data during continuous
            % operation (stop acts as an abort)
            if obj.IsContinuous
                emptyAcquisitionQueue = false;            
            end
            
            while numElementsAvailable >= notifySize ||...
                    (emptyAcquisitionQueue && numElementsAvailable > 0)
                
                % g1545290
                % Retrieve _up to_ NotifyWhenDataAvailableExceeds scans,
                % create the DataAvailableInfo object, and fire the event
                data = obj.AcquisitionQueue.read(double(notifySize));
                
                % Create the DataAvailableInfo object, and fire the event
                dataAvailableInfo = daq.DataAvailableInfo(obj.TriggerTime, data);
                
                % G636062 Keep track of the number of scans notified for
                % this operation and break out of the while when we've
                % notified for as many scans as requested.

                totalScansAvailable = obj.TotalScansAvailableNotified + uint64(size(data, 1));
                
                if (totalScansAvailable >= obj.NumberOfScans)
                    % G650896: Extra events when acquiring fractional buffers
                    scansToNotify = double(obj.NumberOfScans - obj.TotalScansAvailableNotified);
                    if scansToNotify > 0
                        dataAvailableInfo = daq.DataAvailableInfo(obj.TriggerTime, data(1:scansToNotify, :));
                        notify(obj,'DataAvailable',dataAvailableInfo)
                        obj.TotalScansAvailableNotified = obj.TotalScansAvailableNotified + scansToNotify;
                    end
                    break;
                end
                
                % G650896: Extra events when acquiring fractional buffers
                notify(obj,'DataAvailable', dataAvailableInfo)
                obj.TotalScansAvailableNotified = totalScansAvailable;
                numElementsAvailable = obj.AcquisitionQueue.NumElementsAvailable;
            end
        end
        
        function errorOnInvalidOutputData(obj,dataToOutput)
            if obj.Channels.countOutputChannels() == 0
                obj.localizedError('daq:Session:noOutputChannels')
            end
            if ~ismatrix(dataToOutput) || ~daq.internal.isNumericNum(dataToOutput)
                obj.localizedError('daq:Session:invalidDataFormat')
            end
            if size(dataToOutput,2) ~= obj.Channels.countOutputChannels()
                % The output data should have the same number of columns as
                % there are output channels
                obj.localizedError('daq:Session:incorrectColumnCount')
            end
            if size(dataToOutput,1) < 1
                % The output data should have at least one row
                obj.localizedError('daq:Session:invalidDataFormat')
            end
            
            % G633205 Ensure that the data is not out of range.
            obj.Channels.errorIfOutOfRange(dataToOutput);
        end
        
        function updatePropertiesAfterQueuingData(obj,dataToOutput)
            obj.ScansTransferred = uint64(double(obj.ScansTransferred) + size(dataToOutput,1));
            obj.ScansQueued = uint64(double(obj.ScansTransferred) - double(obj.ScansOutputByHardware));
            
            if obj.IsContinuous == false
                % Updates NumberOfScans to be ScansQueued.
                obj.ScanQueuingInProgress = true;
                obj.NumberOfScans = obj.ScansQueued;
                obj.ScanQueuingInProgress = false;
            end
            
            % Reset the flag that prevents DataRequired events
            obj.IsWaitingForQueueOutputData = false;
        end
        
        function transferAccumulatedOutputScansToVendor(obj)
            % This only gets called if there are channels in the session,
            % and prepareHook() function has been called.
            
            % Call the vendor implementation to queue the data to hardware.
            if ~isempty(obj.GenerationQueue)
                obj.queueOutputDataImpl(obj.GenerationQueue.readScansFromQueue());
            end
        end
        
        function forceResetCounters(obj)
            try
                % Attempt to reset counters after any errors (to ensure
                % counters are still running)
                obj.resetCountersImpl();
            catch e %#ok<NASGU>
            end
        end
        
        function releaseInternal(obj)
            obj.IsReleaseInternal = true;
            try
                obj.release();
                obj.IsReleaseInternal = false;
            catch e
                obj.IsReleaseInternal = false;
                rethrow(e);
            end
        end
        
        function flushIfOutputChannelsUpdated(obj, subsystem, measurementType)
            % When an output channel is updated (add/remove), the flush
            % output data (function generations are not flushed)
            if subsystem == daq.internal.SubsystemType.AnalogOutput ||...
               subsystem == daq.internal.SubsystemType.AudioOutput ||...     
               (subsystem == daq.internal.SubsystemType.DigitalIO && strcmpi(measurementType, 'OutputOnly'))
                obj.flushOutputData(true);
            end              
        end
        
        function fireDurationIncreasedWarning(obj, newDuration)
            if obj.FireDurationIncreasedWarning
                obj.localizedWarning('daq:Session:durationIncreased',num2str(newDuration))
            end
        end
    end
end

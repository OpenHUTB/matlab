function hfcns = slrealtime_extmode()
%

% Copyright 2019-2021 The MathWorks, Inc.

    hfcns.i_UserHandleError           = @i_UserHandleError;
    hfcns.i_UserInit                  = @i_UserInit;
    hfcns.i_UserConnect               = @i_UserConnect;
    hfcns.i_UserSetParam              = @i_UserSetParam;
    hfcns.i_UserGetParam              = @i_UserGetParam;
    hfcns.i_UserSignalSelect          = @i_UserSignalSelect;
    hfcns.i_UserSignalSelectFloating  = @i_UserSignalSelectFloating;
    hfcns.i_UserTriggerSelect         = @i_UserTriggerSelect;
    hfcns.i_UserTriggerSelectFloating = @i_UserTriggerSelectFloating;
    hfcns.i_UserTriggerArm            = @i_UserTriggerArm;
    hfcns.i_UserTriggerArmFloating    = @i_UserTriggerArmFloating;
    hfcns.i_UserCancelLogging         = @i_UserCancelLogging;
    hfcns.i_UserCancelLoggingFloating = @i_UserCancelLoggingFloating;
    hfcns.i_UserStart                 = @i_UserStart;
    hfcns.i_UserStop                  = @i_UserStop;
    hfcns.i_UserPause                 = @i_UserPause;
    hfcns.i_UserStep                  = @i_UserStep;
    hfcns.i_UserContinue              = @i_UserContinue;
    hfcns.i_UserGetTime               = @i_UserGetTime;
    hfcns.i_UserDisconnect            = @i_UserDisconnect;
    hfcns.i_UserDisconnectImmediate   = @i_UserDisconnectImmediate;
    hfcns.i_UserDisconnectConfirmed   = @i_UserDisconnectConfirmed;
    hfcns.i_UserTargetStopped         = @i_UserTargetStopped;
    hfcns.i_UserFinalUpload           = @i_UserFinalUpload;
    hfcns.i_UserCheckData             = @i_UserCheckData;
    hfcns.i_UserProcessUpBlock        = @i_UserProcessUpBlock;
end

%**************************************************************************
%                          PUBLIC FUNCTIONS
%**************************************************************************

function glbVars = i_UserHandleError(glbVars, action) %#ok
%
% Called when a try...catch statement has failed and an error is thrown.
% The input argument 'action' is the message that caused the error.
%

end % i_UserHandleError

function glbVars = i_UserInit(glbVars)
%
% Called at the very beginning of the External Mode connect process before
% the model has been compiled and before the 'Connect' message has been
% issued.  This is the place to perform any initialization needed at the
% start of an External Mode session, so long as the model checksum is not
% changed (which will cause the ensuing 'Connect' message to fail).
%

    % These warnings are thrown by the Simulink engine, but are not
    % relevant for SLRT etxmode and are suppressed.
    %
    locManageWarnings(true);
    
    glbVars.slrealtime.tg = []; % target object
    glbVars.slrealtime.badgedInstObj = []; % instrumentation object for badged signals
    glbVars.slrealtime.instObj = []; % instrumentation object for streaming signals
    glbVars.slrealtime.instMap = []; % maps an upload block to its source signals
    glbVars.slrealtime.lastExecTime = 0; % time for the model status bar
    glbVars.slrealtime.mlObsDataArray = [];

    % Override duration set by user.
    % Duration is no longer used by slrealtime but should be large to
    % handle the amount of data sent to Simulink.  If started from the
    % toolstrip "run-on-target" button, the user's original duration value
    % will be restored.
    %
    origDirty = get_param(glbVars.glbModel, 'Dirty');
    set_param(glbVars.glbModel, 'ExtModeTrigDuration', 100000);
    if strcmp(origDirty, 'off')
        set_param(glbVars.glbModel, 'Dirty', 'off');
    end

    locProcessUpBlocksFlag(false); % flag to enable/disable processing of signals
    locProcessCheckForStoppedTargetFlag(false); % flag to enable/disable checking for stopped target

end % i_UserInit

function [glbVars, status, checksum1, checksum2, checksum3, checksum4,...
    intCodeOnly, tgtStatus] = i_UserConnect(glbVars)
%
% Perform all operations needed to create a connection with the target
% executable.  The following information is returned:
%
%  1) glbVars     - If changes to global variables are needed.
%  2) status      - Was there an error during the connect process.
%  3) checksum1
%     checksum2
%     checksum3
%     checksum4   - Target executable checksum.
%  4) intCodeOnly - Is target executable built as integer only (no floats).
%  5) tgtStatus   - Is target executable running (3) or waiting to be started (1).
%
    status = 0; % assume no error

    % Create target object from target computer selection in toolstrip.
    %
    appContext = slrealtime.internal.ToolStripContextMgr.getContext(glbVars.glbModel);
    targetPCName = appContext.selectedTarget;
    glbVars.slrealtime.tg = slrealtime(targetPCName);
    
    % This model must be loaded on the target to connect.
    %
    if ~glbVars.slrealtime.tg.isLoaded(glbVars.glbModel)
        locThrowError('slrealtime:extmode:appNotLoaded', glbVars.glbModel, glbVars.slrealtime.tg.TargetSettings.name);
    end
    
    % Return checksums of application on target computer.
    %
    codeDesc = coder.getCodeDescriptor(glbVars.slrealtime.tg.get('mldatxCodeDescFolder'), 247362);
    dmr_model = codeDesc.getMF0FullModel;
    scm = SharedCodeManager.ModelInterface(fullfile(glbVars.slrealtime.tg.get('mldatxCodeDescFolder'), dmr_model.sharedCodeManagerPath, 'shared_file.dmr'));
    modelData = scm.retrieveModelData(glbVars.glbModel, 'SLBUILD');
    checksum1 = double(modelData.ModelChecksum(1));
    checksum2 = double(modelData.ModelChecksum(2));
    checksum3 = double(modelData.ModelChecksum(3));
    checksum4 = double(modelData.ModelChecksum(4));
    
    intCodeOnly = 0;
    
    running = glbVars.slrealtime.tg.isRunning(glbVars.glbModel);
    if running
        tgtStatus = 3;
    else
        tgtStatus = 1;
    end
    
end % i_UserConnect

function [glbVars, status] = i_UserSetParam(glbVars, params)
%
% Download the values of the specified parameters to the target executable.
% The input argument 'params' is an array of structures with the following
% fields:
%
%             BlockName - Full pathname of block owning the parameter or
%                         empty if workspace parameter.
%         ParameterName - Name of parameter to download.
%          DataTypeName - Data type name of parameter to download.
%   DataTypeStorageName - Storage data type name of parameter to download.
%                Values - Parameter values to download.
%
    status = 0;
 
    codeDesc = coder.getCodeDescriptor(glbVars.slrealtime.tg.get('mldatxCodeDescFolder'), 247362);

    sess = Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.simulinkCoder);
    c = onCleanup(@()delete(sess));
    
    for i = 1:length(params)
        p = params(i);
        if isempty(p.BlockName)
            p.BlockName = '';
        else
            try
                blk = get_param(p.BlockName, 'Object');
            catch
                % Skip parameter if invalid block.
                continue;
            end
            
            if blk.isSynthesized
                % Skip synthesized blocks because they may not be in
                % Code Descriptor.  Users can't change synthesized block
                % parameters anyway, so skipping them should be OK.
                continue;
            end

            if isa(blk, 'Simulink.SFunction')
                rto = blk.RuntimeObject;
                skip = true;
                for nRTP=1:rto.NumRuntimePrms
                    if strcmp(rto.RuntimePrm(nRTP).Name, p.ParameterName)
                        skip = false;
                        break;
                    end
                end
                if skip
                    % Skip s-function parameters which are not run time
                    % param because they may not be in Code Descriptor.
                    continue;
                end
            end
        end
        
        try
            glbVars.slrealtime.tg.setparam(p.BlockName, p.ParameterName, p.Values, 'CodeDescriptor', codeDesc);
        catch ME
            locThrowWarning('slrealtime:extmode:setParamWarning', ME.message);
        end
    end

end % i_UserSetParam

function [glbVars, status, params] = i_UserGetParam(glbVars)
%
% Upload the values of the specified parameters from the target executable.
% See i_UserSetParam() for an example of how to construct the return
% argument 'params'.
%
    status = 0;

    params = []; % Not yet supported by External mode open protocol

end % i_UserGetParam

function [glbVars, status] = i_UserSignalSelect(glbVars)
%
% Setup the target executable to upload the signals specified in the cell array
% glbVars.glbUpInfoWired.upBlks.  Each cell in the array is a struct with the
% following fields
%
%   Name              - Full pathname of the uploading block.
%   SrcSignals        - Cell array of source signals to upload.
%   LogEventCompleted - Indicates if the block has completed uploading all data
%                       associated with a logging event.
%
% SrcSignals is a cell array of structs with the following fields:
%
%   Timeseries - Timeseries object completely describing the source signal
%                to upload and providing the buffers for time and data.
%
% Example:
%   Suppose a model has a single scope being uploaded.  In this case, the
%   glbVars.glbUpInfoWired.upBlks may look like the following:
%
%     >> glbVars.glbUpInfoWired.upBlks
%     glbVars.glbUpInfoWired.upBlks
%
%     ans =
%
%         [1x1 struct]
%
%     >> glbVars.glbUpInfoWired.upBlks{1}
%     glbVars.glbUpInfoWired.upBlks{1}
%
%     ans =
%
%               Name: 'mopen_intrf_wide/Scope'
%         SrcSignals: {[1x1 struct]  [1x1 struct]  [1x1 struct]}
%  LogEventCompleted: 0
%
%     >> glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}
%     glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}
%
%     ans = 
%
%        SrcSignal with properties:
%
%        BlockPath: 'mopen_intrf_wide/Source2'
%        PortIndex: 1
%          SigName: ''
%       SampleTime: 2.5000e-04
%       Timeseries: [1×1 timeseries]
%
%     >> glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}.Timeseries
%     glbVars.glbUpInfoWired.upBlks{1}.SrcSignals{2}.Timeseries
%               Name: 'unnamed2'
%          BlockPath: 'mopen_intrf_wide/Source2'
%          PortIndex: 1
%         SignalName: ''
%         ParentName: 'unnamed2'
%           TimeInfo: [1x1 Simulink.TimeInfo]
%               Time: []
%               Data: [0x3 embedded.fi]
%
    status = 0;
    
    % Add all instrumented signals from the model to a separate instrument.
    %
    mldatxfile = which([glbVars.glbModel '.mldatx']);
    glbVars.slrealtime.badgedInstObj = slrealtime.Instrument(mldatxfile);
    glbVars.slrealtime.badgedInstObj.RemoveOnStop = true;
    glbVars.slrealtime.badgedInstObj.MLObsDropIfBusy = false;
    glbVars.slrealtime.badgedInstObj.StreamingOnly = true;
    glbVars.slrealtime.badgedInstObj.addInstrumentedSignals();

    % Add all signals needed by extmode to a separate instrument.
    %
    mldatxfile = which([glbVars.glbModel '.mldatx']);   
    glbVars.slrealtime.instObj = slrealtime.Instrument(mldatxfile);
    glbVars.slrealtime.instObj.RemoveOnStop = true;
    glbVars.slrealtime.instObj.MLObsDropIfBusy = false;
    glbVars.slrealtime.instObj.StreamingOnly = false;
    glbVars.slrealtime.instObj.connectCallback(@(obj,data)slrealtime_extmode_cb(glbVars.glbModel, obj, data));

    % Add all necessary source signals connected to dashboard blocks.
    %
    boundEls = Simulink.HMI.getElementsBoundToVisualizationBlocks(glbVars.glbModel);
    for nBoundEl=1:length(boundEls)
        for nPort=1:length(boundEls(nBoundEl).BoundPorts)
            glbVars.slrealtime.instObj.addSignal(...
                boundEls(nBoundEl).BlockPath, ...
                boundEls(nBoundEl).BoundPorts(nPort));
        end
    end
    
    % Add all necessary source signals connected to uploading blocks.
    %
    codeDesc = []; % Code Descriptor and Block Hierarchy Map are needed
    bhm      = []; % only when states are being uploaded
    glbVars.slrealtime.instMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
    upInfo = glbVars.glbUpInfoWired;
    for nUpBlk=1:length(upInfo.upBlks)        
        
        if ~glbVars.slrealtime.instMap.isKey(nUpBlk)
            glbVars.slrealtime.instMap(nUpBlk) = [];
        end
        
        try
            % Process source signals.
            %
            for nUpBlkSrcSig=1:length(upInfo.upBlks{nUpBlk}.SrcSignals)
                [agi, si] = glbVars.slrealtime.instObj.addSignal(...
                    upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.BlockPath, ...
                    upInfo.upBlks{nUpBlk}.SrcSignals{nUpBlkSrcSig}.PortIndex);
                
                val = struct( ...
                    'agi', agi, ...
                    'si', si, ...
                    'srcType', 'S', ...
                    'srcIdx', nUpBlkSrcSig, ...
                    'dataType', []);
                
                glbVars.slrealtime.instMap(nUpBlk) = [glbVars.slrealtime.instMap(nUpBlk) val];
            end
            
            % Process source modelref signals.
            %
            for nUpBlkSrcMRSig=1:length(upInfo.upBlks{nUpBlk}.SrcMRSignals)
                [agi, si] = glbVars.slrealtime.instObj.addSignal(...
                    upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcMRSig}.BlockPath.convertToCell, ...
                    upInfo.upBlks{nUpBlk}.SrcMRSignals{nUpBlkSrcMRSig}.PortIndex);
                
                val = struct( ...
                    'agi', agi, ...
                    'si', si, ...
                    'srcType', 'M', ...
                    'srcIdx', nUpBlkSrcMRSig, ...
                    'dataType', []);
                
                glbVars.slrealtime.instMap(nUpBlk) = [glbVars.slrealtime.instMap(nUpBlk) val];
            end
            
            % Process source dworks.
            %
            if isempty(codeDesc) && isempty(bhm)
                % Open Code Descriptor and Block Hierarchy Map only once,
                % and only if needed.
                codeDesc = coder.getCodeDescriptor(glbVars.slrealtime.tg.get('mldatxCodeDescFolder'), 247362);
                bhm = codeDesc.getBlockHierarchyMap;
            end
        
            %
            % See g2504515/g2601076
            % Stateflow charts animate in extmode, but we can not write
            % automated tests to actually see the animation happening.
            % Instead, we write out the dworks and verify they are correct.
            % This provides some level of automated testing to catch any
            % bugs in stateflow animation support for SLRT.
            %
            if slrealtime.internal.feature('StateflowAnimationTesting')
                assignin('base', ...
                    'TMW_SLRT_EXTMODE_STATEFLOW_ANIMATION_TESTING', ...
                    upInfo.upBlks{nUpBlk}.SrcDWorks);
            end

            for nUpBlkSrcDWorkSig=1:length(upInfo.upBlks{nUpBlk}.SrcDWorks)
                blk = locGetBlockFromCodeDescriptor(bhm, upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcDWorkSig}.BlockPath);
                if isempty(blk), continue; end % TODO Should this be an error or warning?
                
                % External mode can stream Stateflow data, this is a
                % mapping from Stateflow information (SSID, Logging Mode)
                % that Simulink sends down to target memory addresses.
                try
                    sfInfoArray = blk.StateflowLoggingMap.toArray;
                catch
                    sfInfoArray = [];
                end
                if isempty(sfInfoArray), continue; end
                
                ssid = upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcDWorkSig}.SSID;
                desc = upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcDWorkSig}.Description;
                switch desc
                    case {'StateTestPoint', 'StateIsActive'}
                        mode = coder.descriptor.LoggingModeEnum.SELF_ACTIVITY;
                        desc = ':IsActive';
                    case {'StateActiveChild'}
                        mode = coder.descriptor.LoggingModeEnum.CHILD_ACTIVITY;
                        desc = ':ActiveChild';
                    case {'StateflowLeafActivity'}
                        mode = coder.descriptor.LoggingModeEnum.LEAF_ACTIVITY;
                        desc = ':ActiveLeaf';
                    otherwise
                        %case {'ChartLocal'}
                        mode = coder.descriptor.LoggingModeEnum.LOCAL_DATA;
                        desc = '';
                end
                
                sfInfo = sfInfoArray(arrayfun(@(x)(x.StateflowLoggingTuple.LoggingMode == mode && x.StateflowLoggingTuple.Ssid == ssid), sfInfoArray));
                if ~isempty(sfInfo)
                    % There might be multiple entries returned.
                    % For example, if a state was testpointed it
                    % might show up twice in the generated code
                    % with two different target memory addresses.
                    % It should be OK to just pick one of the
                    % entries (the data should be identical).
                    [agi, si] = glbVars.slrealtime.instObj.addSignal(...
                        upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcDWorkSig}.BlockPath, ...
                        [sfInfo(1).StateflowLoggingTuple.SourceObjectName desc], ...
                        'MetaData', struct( ...
                        'ssid', sfInfo(1).StateflowLoggingTuple.Ssid, ...
                        'loggingMode', sfInfo(1).StateflowLoggingTuple.LoggingMode));
                    
                    val = struct( ...
                        'agi', agi, ...
                        'si', si, ...
                        'srcType', 'D', ...
                        'srcIdx', nUpBlkSrcDWorkSig, ...
                        'dataType', upInfo.upBlks{nUpBlk}.SrcDWorks{nUpBlkSrcDWorkSig}.DataType ...
                        );
                    
                    glbVars.slrealtime.instMap(nUpBlk) = [glbVars.slrealtime.instMap(nUpBlk) val];
                end
            end
        catch ME
            % Failed to add a signal.  One possibility is the signal is
            % fixed-point (which is not yet supported).  Remove the
            % uploading block and throw a warning.
            %
            if strcmp(ME.identifier, 'slrealtime:instrument:DataTypeCannotBeInstrumented')
                locThrowWarning('slrealtime:extmode:unsupportedDataType', upInfo.upBlks{nUpBlk}.Name);
            else
                locThrowWarning('slrealtime:extmode:unsupportedSignal', upInfo.upBlks{nUpBlk}.Name);
            end
            glbVars.slrealtime.instMap(nUpBlk) = [];
        end
    end

    % Start streaming signals if application is running
    if glbVars.slrealtime.tg.isRunning(glbVars.glbModel)
        locProcessUpBlocksFlag(true);
        locProcessCheckForStoppedTargetFlag(true);

        % The order of these calls is important due to g2465315
        % We add the extmode instrument first to ensure Stateflow
        % charts animate correctly.  
        glbVars.slrealtime.tg.addInstrument(glbVars.slrealtime.instObj);
        glbVars.slrealtime.tg.addInstrument(glbVars.slrealtime.badgedInstObj);
    end

end % i_UserSignalSelect

function [glbVars, status] = i_UserSignalSelectFloating(glbVars)
%
% Setup the target executable to upload the signals specified in the cell array
% glbVars.glbUpInfoFloating.upBlks.  See i_UserSignalSelect() for an example of
% how to parse the signals to upload.
%
    status = 0;

    upInfo = glbVars.glbUpInfoFloating;
    for nUpBlk=1:length(upInfo.upBlks)
        locThrowWarning('slrealtime:extmode:noFloatingSupport', upInfo.upBlks{nUpBlk}.Name);
    end

end % i_UserSignalSelectFloating

function [glbVars, status] = i_UserTriggerSelect(glbVars)
%
% Setup the target executable to trigger uploading the selected wired signals.
% The trigger signal is specified in glbVars.glbUpInfoWired.trigger as a struct
% with the following fields (for more in-depth discussion of each field, see
% the External Mode documentation):
%
%   Signal   - Non-empty struct if using a signal as the trigger.
%   OneShot  - If false, trigger re-arms automatically.
%   Duration - Number of base rate steps for which data logging event occurs.
%   BaseRate - Base rate of the model.
%
% If a signal is used as the trigger, the 'Signal' field is a struct with
% the following fields (for more in-depth discussion of each field, see
% the External Mode documentation):
%
%   Name      - Full pathname of the trigger signal block.
%   Port      - Port number of the trigger signal block.
%   Element   - Which element of the signal to use as trigger.
%   Sources   - Cell array of sources comprising the trigger signal.
%   Direction - Direction of trigger signal to fire an upload of data.
%   Level     - Value of trigger signal crossing to start a data logging event.
%   Delay     - Number of base rate steps to wait after trigger fires to begin
%               collecting data.
%   Holdoff   - Number of base rate steps to wait before re-arming the trigger.
%
% Sources is a cell array of structs with the following fields:
%
%   Name    - Full pathname of the source signal block.
%   Port    - Port number of the source signal block.
%   Element - Which element of the source signal is used to trigger.
%
% Example:
%   Suppose a model has a single scope being uploaded using a trigger signal
%   to start a data logging event.  In this case, glbVars.glbUpInfoWired.trigger
%   may look like the following:
%
%   >> glbVars.glbUpInfoWired.trigger
%   glbVars.glbUpInfoWired.trigger
%
%   ans =
%
%         Signal: [1x1 struct]
%        OneShot: 0
%       Duration: 100
%       BaseRate: 0.1000
%
%   >> glbVars.glbUpInfoWired.trigger.Signal
%   glbVars.glbUpInfoWired.trigger.Signal
%
%   ans =
%
%            Name: 'mopen_intrf_wide/Scope'
%            Port: 1
%         Element: 'any'
%         Sources: {2x1 cell}
%       Direction: 'rising'
%           Level: 0
%           Delay: 0
%         HoldOff: 0
%
%   >> glbVars.glbUpInfoWired.trigger.Signal.Sources{2}
%   glbVars.glbUpInfoWired.trigger.Signal.Sources{2}
%
%   ans =
%
%          Name: 'mopen_intrf_wide/Source1'
%          Port: 1
%       Element: 2
%
    status = 0;
    
end % i_UserTriggerSelect

function [glbVars, status] = i_UserTriggerSelectFloating(glbVars)
%
% Setup the target executable to trigger uploading the selected floating
% signals.  See i_UserTriggerSelect() for an example of how to parse the
% trigger.
%
    status = 0;

end % i_UserTriggerSelectFloating

function [glbVars, status] = i_UserTriggerArm(glbVars)
%
% Arm the trigger on the target executable for uploading the selected wired
% signals.
%
    status = 0;

end % i_UserTriggerArm

function [glbVars, status] = i_UserTriggerArmFloating(glbVars)
%
% Arm the trigger on the target executable for uploading the selected floating
% signals.
%
    status = 0;

end % i_UserTriggerArmFloating

function [glbVars, status] = i_UserCancelLogging(glbVars)
%
% Cancel logging on the target executable for uploading the selected wired
% signals.
%
    status = 0;
    
    locProcessUpBlocksFlag(false);
    locProcessCheckForStoppedTargetFlag(false);
    if ~isempty(glbVars.slrealtime.badgedInstObj)
        glbVars.slrealtime.tg.removeInstrument(glbVars.slrealtime.badgedInstObj);
        glbVars.slrealtime.badgedInstObj = [];
    end
    if ~isempty(glbVars.slrealtime.instObj)
        glbVars.slrealtime.tg.removeInstrument(glbVars.slrealtime.instObj);
        glbVars.slrealtime.instObj = [];
    end
    
end % i_UserCancelLogging

function [glbVars, status] = i_UserCancelLoggingFloating(glbVars)
%
% Cancel logging on the target executable for uploading the selected floating
% signals.
%
    status = 0;

end % i_UserCancelLoggingFloating

function [glbVars, status] = i_UserStart(glbVars)
%
% Start the target executable.
%
    status = 0;
    
    tg = glbVars.slrealtime.tg;
    
    if ~tg.isLoaded
        % If no model is loaded, a restart must have been requested.
        %
        glbVars.slrealtime.lastExecTime = 0;
        tg.load(glbVars.glbModel);
    end
    
    locProcessUpBlocksFlag(true);
    
    % The order of these calls is important due to g2465315
    % We add the extmode instrument first to ensure Stateflow
    % charts animate correctly.  
    if ~isempty(glbVars.slrealtime.instObj)
        tg.addInstrument(glbVars.slrealtime.instObj);
    end
    if ~isempty(glbVars.slrealtime.badgedInstObj)
        tg.addInstrument(glbVars.slrealtime.badgedInstObj);
    end
    
    if ~tg.isRunning()
        % The started listener callback calls tg.start, so tempoararily
        % disable it because we don't want tg.start called twice.
        % Disable the stopped listener so the target does not terminate the
        % extmode simulation while still processing the start command (e.g.
        % if the start time is very small).  This listener will be
        % re-enabled when extmode terminates.
        locToolstripStartedListenerEnabled(glbVars, false);
        locToolstripStoppedListenerEnabled(glbVars, false);
        % Get the AutoImportFileLog flag from the Simulink Toolstrip
        appContext = slrealtime.internal.ToolStripContextMgr.getContext(glbVars.glbModel);
        tg.start('AutoImportFileLog', appContext.autoImportFileLogFlagSelected);
        locToolstripStartedListenerEnabled(glbVars, true);
    end
    
    if ~isempty(tg.ModelStatus.Error)
        locThrowError('slrealtime:extmode:startError', ...
            glbVars.glbModel, ...
            glbVars.slrealtime.tg.TargetSettings.name, ...
            tg.ModelStatus.Error);
    end
    
    % i_UserTargetStopped calls tg.isRunning(), so make sure it returns
    % true before checking if target stopped
    %
    pause(1);
    tstart = tic;
    while toc(tstart) < 10
        if tg.isRunning()
            break;
        end
    end
    locProcessCheckForStoppedTargetFlag(true);
    
end % i_UserStart

function [glbVars, status] = i_UserStop(glbVars)
%
% Stop the target executable.
%
    status = 0;
    
    locProcessUpBlocksFlag(false);
    locProcessCheckForStoppedTargetFlag(false);
    
    if glbVars.restarting
        % Disable stopped listener during a restart because we want to stay
        % connected to extmode and the listener will force a disconnect.
        %
        locToolstripStoppedListenerEnabled(glbVars, false);
        c = onCleanup(@()locToolstripStoppedListenerEnabled(glbVars, true));
    end

    glbVars.slrealtime.tg.stop;

    try
        appContext = slrealtime.internal.ToolStripContextMgr.getContext(glbVars.glbModel);
        appContext.synchToolStripWithSelectedTarget();
    catch
        % ignore errors
    end

end % i_UserStop

function [glbVars, status] = i_UserPause(glbVars)
%
% Pause the target executable.
%
    status = 0;

end % i_UserPause

function [glbVars, status] = i_UserStep(glbVars)
%
% From a paused state, step the target executable one time step and return
% to a paused state.
%
    status = 0;

end % i_UserStep

function [glbVars, status] = i_UserContinue(glbVars)
%
% From a paused state, continue running the target executable.
%
    status = 0;

end % i_UserContinue

function [glbVars, time] = i_UserGetTime(glbVars)
%
% Get the simulation time from the target executable.
%
    tg = glbVars.slrealtime.tg;
    time = tg.get('tc.ModelExecProperties.ExecTime');
    if time > glbVars.slrealtime.lastExecTime
        glbVars.slrealtime.lastExecTime = time;
    else
        time = glbVars.slrealtime.lastExecTime;
    end

end % i_UserGetTime

function [glbVars, status] = i_UserDisconnect(glbVars)
%
% Perform all operations needed to close a connection with the target
% executable.  This is considered a normal disconnection.
%
    status = 0;

end % i_UserDisconnect

function glbVars = i_UserDisconnectImmediate(glbVars)
%
% Perform all operations needed to close a connection with the target
% executable.  This is considered an abnormal disconnection resulting
% from some kind of error.  Simulink issues this action during an
% ungraceful connection and does not even know if communication with
% the target is still possible.  In this case, a 'DisconnectConfirmed'
% action will not be sent from Simulink.
%
    glbVars = locCleanup(glbVars);
    
end % i_UserDisconnectImmediate

function glbVars = i_UserDisconnectConfirmed(glbVars)
%
% Perform any operations needed after Simulink has confirmed the connection
% is closed.
%
    glbVars = locCleanup(glbVars);
    
end % i_UserDisconnectConfirmed

function [glbVars, status] = i_UserTargetStopped(glbVars)
%
% Returns true if the target has stopped, false otherwise.
%
    status = 0;

    if ~locProcessCheckForStoppedTargetFlag()
        return;
    end

    try
        tg = glbVars.slrealtime.tg;
        if ~tg.isRunning
            status = 1;
            locProcessUpBlocksFlag(false);
            locProcessCheckForStoppedTargetFlag(false);
            appContext = slrealtime.internal.ToolStripContextMgr.getContext(glbVars.glbModel);
            appContext.synchToolStripWithSelectedTarget();
        end
    catch
        % ignore errors
    end

end % i_UserTargetStopped

function glbVars = i_UserFinalUpload(glbVars)
%
% Uploads one last burst of data before the target shuts down.
%
% EqualLengthVectors must be off during the final upload because we may not
% have a full duration worth of data, so there is no guarantee that each
% source has acquired the same amount of data.
%

    i_UserCheckData(glbVars, glbVars.glbUpInfoWired);

end % i_UserFinalUpload

function glbVars = i_UserCheckData(glbVars, upInfo) %#ok
%
% This function is called periodically from Simulink to continuously
% check the target for available data.  Each uploading block specified
% in 'upInfo' is made up of some number of source signals.  Each source
% signal must have data uploaded from the target before the uploading
% block can be executed.  When data for a particular source signal is
% uploaded, the data must be written into the appropriate TimeSeries
% object via a call to:
%
%   glbVars = i_WriteSourceSignal(glbVars, src, time, data);
%
% The data written into the TimeSeries object must be the same type as
% the source signal in the Simulink model.  Also, fixed-point data must
% be in Stored Integer (SI).  To convert Real World Values (RWV) into
% SI form of the appropriate type, use the following:
%
%   data = i_ConvertRWVToSI(dType, block, raw_data);
%
% Once all source signals for a particular uploading block have been
% written, the block must be executed via a call to:
%
%   glbVars = i_SendBlockExecute(glbVars, upInfoIdx, nUpBlk);
%
% The data for a particular logging event (one duration worth of data)
% does not have to be uploaded all at once.  When all of the data has
% been uploaded (whether it was in one chunk or spaced out over several
% calls to i_SendBlockExecute), the uploading block must be marked as
% completed via a call to:
%
%   glbVars = i_BlockLogEventCompleted(glbVars, upInfo.index, nUpBlk);
%

    mlObsDataArray = glbVars.slrealtime.mlObsDataArray;
    glbVars.slrealtime.mlObsDataArray = [];
    
    for nMLObsData = 1:length(mlObsDataArray)
        
        mlObsData = mlObsDataArray(nMLObsData);
        
        upInfo = glbVars.glbUpInfoWired; % Only wired is supported
        
        if isempty(upInfo) || ~upInfo.trigger_armed
            return;
        end
        
        % Process each uploading block.
        %
        for nUpBlk=1:length(upInfo.upBlks)
            upBlk = upInfo.upBlks{nUpBlk};
            
            if upBlk.LogEventCompleted
                continue;
            end
            if isempty(upBlk.SrcSignals) && ...
                    isempty(upBlk.SrcMRSignals) && ...
                    isempty(upBlk.SrcDWorks)
                glbVars = feval(glbVars.utilsFile.i_BlockLogEventCompleted, glbVars, upInfo.index, nUpBlk);
                continue;
            end
            
            % Write all source data to timeseries.
            %
            executeBlock = true;
            upBlkSrcInfos = glbVars.slrealtime.instMap(nUpBlk);            
            if isempty(upBlkSrcInfos), continue; end
            
            for nUpBlkSrcInfo=1:length(upBlkSrcInfos)
                upBlkSrcInfo = upBlkSrcInfos(nUpBlkSrcInfo);
                
                if upBlkSrcInfo.agi == -1 || upBlkSrcInfo.si == -1
                    % Invalid signal
                    executeBlock = false;
                    continue;
                end
                
                acqGroup = mlObsData.AcquireGroupData(upBlkSrcInfo.agi);

                dropData = false;
                duration = glbVars.glbUpInfoWired.trigger.Duration;
                if ~isempty(acqGroup.Time)
                    time = acqGroup.Time;
                    if length(time) > duration
                        time = time(1:duration);
                        dropData = true;
                    end
                else
                    executeBlock = false;
                    continue;
                end
            
                if ~isempty(acqGroup.Data)
                    data = acqGroup.Data{upBlkSrcInfo.si};
                    if dropData
                        data = data(1:duration);
                    end
                else
                    executeBlock = false;
                    continue;
                end
                if isempty(data)
                    executeBlock = false;
                    continue;
                end
                
                %     % TODO Matlab observers are supplying enum data as storage type,
                %            so this isn't needed right now.  But in the future they might
                %            supply enum data as the enum type, and then we will have to
                %            convert that data into the storage type.  I believe the
                %            storage type can be found in the acqGroup info.
                %
                %     % Convert enum data to proper data storage type.
                %     if isenum(data)
                %         data = feval(type, data);
                %     end
                
                % Convert char arrays to strings.
                if iscell(data) && ischar(data{1})
                    data = string(data);
                end
                
                switch upBlkSrcInfo.srcType
                    case 'S'
                        glbVars = glbVars.utilsFile.i_WriteSourceSignal(glbVars, upInfo.index, nUpBlk, upBlkSrcInfo.srcIdx, time, data);
                    case 'M'
                        glbVars = glbVars.utilsFile.i_WriteSourceMRSignal(glbVars, upInfo.index, nUpBlk, upBlkSrcInfo.srcIdx, time, data);
                    case 'D'
                        glbVars = glbVars.utilsFile.i_WriteSourceDWork(glbVars, upInfo.index, nUpBlk, upBlkSrcInfo.srcIdx, time, eval([upBlkSrcInfo.dataType '(data)']));
                end
            end
            
            % Execute the block.
            %
            if executeBlock
                glbVars = feval(glbVars.utilsFile.i_SendBlockExecute, glbVars, upInfo.index, nUpBlk);
            end
        end
    end

end % i_UserCheckData

function glbVars = i_UserProcessUpBlock(glbVars, nUpBlk, ~, ~, ~, ~) %srcType, nSrcIdx, data, time)

    mlObsData = nUpBlk; % TODO add comment about how this function is being used!
    glbVars.slrealtime.mlObsDataArray = [glbVars.slrealtime.mlObsDataArray mlObsData];

end % i_UserProcessUpBlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%               User-Defined Support Functions Below                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This section of code is used for any user-defined support functions.
% These functions may be called from any of the user-implemented External
% Mode Open Protocol Functions defined above.
%

function locThrowError(errId, varargin)
    msg = message(errId, varargin{:});
    throw(MException(errId, '%s', msg.getString()));
end

function locThrowWarning(warnId, varargin)
    w=warning('off', 'backtrace');
    MSLDiagnostic(warnId, varargin{:}).reportAsWarning;
    warning(w);
end

function locToolstripStartedListenerEnabled(glbVars, val)
    appContext = slrealtime.internal.ToolStripContextMgr.getContext(glbVars.glbModel);
    appContext.startedListener.Enabled = val;
end

function locToolstripStoppedListenerEnabled(glbVars, val)
    appContext = slrealtime.internal.ToolStripContextMgr.getContext(glbVars.glbModel);
    appContext.stoppedListener.Enabled = val;
end

function glbVars = locCleanup(glbVars)
    locManageWarnings(false);
    
    try
        locToolstripStoppedListenerEnabled(glbVars, true);
        locProcessUpBlocksFlag(false);
        locProcessCheckForStoppedTargetFlag(false);
        if ~isempty(glbVars.slrealtime.badgedInstObj)
            glbVars.slrealtime.tg.removeInstrument(glbVars.slrealtime.badgedInstObj);
            glbVars.slrealtime.badgedInstObj = [];
        end
        if ~isempty(glbVars.slrealtime.instObj)
            glbVars.slrealtime.tg.removeInstrument(glbVars.slrealtime.instObj);
            glbVars.slrealtime.instObj = [];
        end
    catch
        % ignore errors
    end

    % Check for simulation errors
    tg = glbVars.slrealtime.tg;
    if ~isempty(tg.ModelStatus) && ~isempty(tg.ModelStatus.Error)
        locThrowError('slrealtime:extmode:simError', ...
            glbVars.glbModel, ...
            tg.TargetSettings.name, ...
            tg.ModelStatus.Error);
    elseif ~isempty(tg.TargetStatus) && ~isempty(tg.TargetStatus.Error)
        locThrowError('slrealtime:extmode:simError', ...
            glbVars.glbModel, ...
            tg.TargetSettings.name, ...
            tg.TargetStatus.Error);
    end

end

function varargout = locProcessUpBlocksFlag(varargin)
    persistent flag;
    if isempty(flag)
        flag = false;
    end
    if nargin > 0
        flag = varargin{1};
    else
        varargout{1} = flag;
    end
end

function varargout = locProcessCheckForStoppedTargetFlag(varargin)
    persistent flag;
    if isempty(flag)
        flag = false;
    end
    if nargin > 0
        flag = varargin{1};
    else
        varargout{1} = flag;
    end
end

function blk = locGetBlockFromCodeDescriptor(bhm, blockpath)
    systems = bhm.getGraphicalSystemByType('root');
    assert(length(systems) == 1);
    sys = systems(1);
    
    [~, remain] = strtok(blockpath, '/');
    [token, remain] = strtok(remain, '/'); % ignore first token (model name)
    
    while ~isempty(remain)
        blocks = sys.getBlocksByName(token);
        if (length(blocks) ~= 1)
            blk = [];
            return;
        end
        sys = blocks(1).GraphicalSubsystem();
        [token, remain] = strtok(remain, '/'); %#ok
    end
    
    blocks = sys.getBlocksByName(token);
    if (length(blocks) == 1)
        blk = blocks(1);
    end
end

function locManageWarnings(suppress)
    persistent suppressed;
    if isempty(suppressed)
        suppressed = false;
    end
    persistent noDataUploadBlocks;
    persistent returnWorkspaceOutputsNotSupportedInExtmode;
    
    if suppress && ~suppressed
        % Suppress warnings if not already suppresed
        suppressed = true;
        noDataUploadBlocks = warning('off', 'Simulink:Engine:NoDataUploadBlocks');
        returnWorkspaceOutputsNotSupportedInExtmode = warning('off','Simulink:Extmode:ReturnWorkspaceOutputsNotSupportedInExtmode');
    elseif ~suppress && suppressed
        % Restore warnings if suppressed
        suppressed = false;
        warning(noDataUploadBlocks);
        warning(returnWorkspaceOutputsNotSupportedInExtmode);
    end
end

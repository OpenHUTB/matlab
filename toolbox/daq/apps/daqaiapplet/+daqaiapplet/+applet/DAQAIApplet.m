classdef DAQAIApplet < matlab.hwmgr.internal.AppletBase
    %DAQAIAPPLET - Main class for the Analog Input Recorder (AIR)

    %   This class defines the initialization, construction, running and
    %   destruction of the Analog Input Recorder (AIR), which is
    %   orchestrated by the Hardware Manager's Plugin Manager Module.
    
    % Copyright 2016-2022 The MathWorks, Inc.
    
    properties(Access = private)
        DaqInitialValues
        ChannelDefaultValues
        CircularBuffer
        InitialWorkspaceVariableName
        
        % This property is left empty if device's default measurement type
        % requires configuration, so classes receiving this property should
        % treat this argument as optional.
        FirstChannelObj
        
        InitialDAQChannelOrderMap
        
        AppTeardownRequestListener
        ErrorRequestListener
        WarningRequestListener
        SignalAnalyzerErrorRequestListener
        DialogRequestListener
        
        % Handles to AIR modules
        Mediator
        DataAcquisitionManager
        ToolstripTabManager
        AppletSpaceManager
        WorkspaceManager
        GenerateScriptManager
        SignalAnalyzerHandler
        ErrorDisplayManager
        WarningDisplayManager
        DialogDisplayManager
        AppStateManager
    end
    
    properties(Constant)
        DisplayName = getString(message('daqaiapplet:DAQAIApplet:AppletTitle'))
        AppletIconSource = fullfile(matlabroot,...
            'toolbox', 'daq', 'apps', 'daqaiapplet', 'icons', 'analogInputRecorder_24.png')

        LicenseRequiredErrorID = "daqappletshared:DAQAppletShared:DAQLicenseRequired"
        LicenseRequiredErrorMsg = getString(message(daqaiapplet.applet.DAQAIApplet.LicenseRequiredErrorID,...
            daqaiapplet.applet.DAQAIApplet.DisplayName))
    end
    
    methods
        function obj = DAQAIApplet()
            try
                daq.Session.checkLicense();
            catch ex
                throwAsCaller(MException(daqaiapplet.applet.DAQAIApplet.LicenseRequiredErrorID,...
                    daqaiapplet.applet.DAQAIApplet.LicenseRequiredErrorMsg));
            end
        end

        function init(obj, hwmgrHandles)
            init@matlab.hwmgr.internal.AppletBase(obj, hwmgrHandles)
            
            % Create Mediator module
            obj.Mediator = matlabshared.mediator.internal.Mediator;
            
            % Create a CircularBuffer object
            obj.CircularBuffer = daqaiapplet.applet.modules.internal.CircularBuffer(obj.Mediator);
            
            % Create the Data Acquisition Manager module
            obj.DataAcquisitionManager = daqaiapplet.applet.modules.DataAcquisitionManager(...
                obj.Mediator, obj.CircularBuffer, obj.DeviceInfo);
            
            % Create Daq object
            obj.DataAcquisitionManager.createDaq();
            
            % Get Channel default values
            obj.ChannelDefaultValues = obj.DataAcquisitionManager.ChannelDefaultValues;
            % Note: If there was an Error propagated from the Data
            % Acquisition Manager while adding channels, then, request
            % Hardware Manager to tear down the App. Once g1543874 is
            % fixed, this code may need update i.e. We may need to check
            % for the add channel Error when we add the first channel.
            if ~isempty(obj.ChannelDefaultValues.Error)
                obj.requestHardwareManagerToDestroyApp();
                return
            end
            
            % Add first channel to daq if device's default measurement type
            % does not require configuration. Audio Subsystem will not have
            % RequiresConfiguration field.
            deviceDefaultMeasurement = obj.DataAcquisitionManager.getDefaultMeasurementType();
            if ~(isfield(obj.ChannelDefaultValues, 'RequiresConfiguration') && obj.ChannelDefaultValues.RequiresConfiguration.(deviceDefaultMeasurement))
                obj.FirstChannelObj = obj.DataAcquisitionManager.addFirstChannel();
            end
            
            obj.InitialDAQChannelOrderMap = obj.DataAcquisitionManager.getDaqChannelOrderMap();         
            
            % Get the Data Acquisition defaults
            obj.DaqInitialValues = obj.DataAcquisitionManager.DaqValues;
            % Add Listeners to Daq object
            obj.DataAcquisitionManager.addDaqListeners();
        end
        
        function construct(obj)
            % Create the Toolstrip Tab Manager module
            obj.ToolstripTabManager = daqaiapplet.applet.modules.ToolstripTabManager(...
                obj.Mediator, obj.ToolstripTabHandle, obj.DaqInitialValues, obj.DeviceInfo.DeviceID);
            
            % Get the Initial Workspace Variable Name so that it could be
            % passed to the WorkspaceManager
            obj.InitialWorkspaceVariableName = obj.ToolstripTabManager.getInitialWorkspaceVariableName();
            
            % Create the Applet Space Manager module
            obj.AppletSpaceManager = daqaiapplet.applet.modules.AppletSpaceManager(...
                obj.Mediator, obj.RootWindow,...
                obj.DeviceInfo, obj.ChannelDefaultValues,...
                obj.CircularBuffer, obj.DaqInitialValues.Rate,...
                obj.FirstChannelObj, obj.InitialDAQChannelOrderMap);
            
            % Create Workspace Manager module
            obj.WorkspaceManager = daqaiapplet.applet.modules.WorkspaceManager(...
                obj.Mediator, obj.CircularBuffer, obj.DaqInitialValues,...
                obj.InitialWorkspaceVariableName);
            
            % Create Generate Script Manager module
            obj.GenerateScriptManager = daqaiapplet.applet.modules.GenerateScriptManager(...
                obj.Mediator, obj.DeviceInfo, obj.InitialWorkspaceVariableName);
            
            % Create the Signal Analyzer Handler module
            obj.SignalAnalyzerHandler = daqaiapplet.applet.modules.SignalAnalyzerHandler(...
                obj.Mediator);
            obj.SignalAnalyzerErrorRequestListener = obj.SignalAnalyzerHandler.listener('ErrorInfo',...
                'PostSet', @(src,event)obj.requestErrorDialog(event.AffectedObject.ErrorInfo));
            
            % Create the Error Display Manager module
            obj.ErrorDisplayManager = daqapplet.shared.modules.ErrorDisplayManager(...
                obj.Mediator, obj.DisplayName);
            obj.ErrorRequestListener = obj.ErrorDisplayManager.listener('ErrorInfo',...
                'PostSet', @(src,event)obj.requestErrorDialog(event.AffectedObject.ErrorInfo));
            
            % Create Info Dialog Display Manager
            obj.WarningDisplayManager = daqapplet.shared.modules.WarningDisplayManager(...
                obj.Mediator, obj.DisplayName);
            obj.WarningRequestListener = obj.WarningDisplayManager.listener('WarningInfo',...
                'PostSet', @(src,event)obj.requestWarningDialog(event.AffectedObject.WarningInfo));

            % Create Confirmation Dialog Display Manager
            obj.DialogDisplayManager = daqapplet.shared.modules.DialogDisplayManager(...
                obj.Mediator, obj.DisplayName);
            obj.DialogRequestListener = obj.DialogDisplayManager.listener('DialogArguments',...
                'PostSet', @(src,event)obj.requestConfirmationDialog(event.AffectedObject.DialogArguments));
            
            % Create the App State Manager module
            obj.AppStateManager = daqaiapplet.applet.modules.AppStateManager(...
                obj.Mediator, obj.DeviceInfo);
            % Listen to 'RequestHardwareManagerToDestroyApp' for requesting
            % hardware manager to teardown the applet
            obj.AppTeardownRequestListener = obj.AppStateManager.listener('RequestHardwareManagerToDestroyApp',...
                'PostSet', @obj.requestHardwareManagerToDestroyApp);
        end
        
        function run(obj)
            % By this point, the applet construction should be complete and
            % hence the modules can subscribe to the properties of their
            % interest from the Mediator object
            obj.Mediator.connect();

            % Publish properties for active channels after connecting
            % Mediator so that subscribers get channel info
            obj.DataAcquisitionManager.publishActiveChannels();
            
            % Publish information about measurements requiring
            % configuration after connecting Mediator so that subscribers
            % (ChannelConfigurationController) know how to handle
            % measurement type edits.
            obj.DataAcquisitionManager.publishMeasurementRequiresConfiguration();
            
            % Start background acquisition
            obj.DataAcquisitionManager.startBackgroundAcquisition();
        end
        
        function destroy(obj)            
            % g2111171: do not ask the DataAcquisitionManager to stop the
            % acquisition as part of destroy (just delete the
            % DataAcquisitionManager).
            
            % Unsubscribe all the property event listeners in all modules
            obj.Mediator.disconnect();
            
            % Delete listener
            delete(obj.AppTeardownRequestListener);
            
            % Delete all modules
            delete(obj.AppStateManager);
            delete(obj.ErrorDisplayManager);
            delete(obj.SignalAnalyzerHandler);
            delete(obj.GenerateScriptManager);
            delete(obj.WorkspaceManager);
            delete(obj.AppletSpaceManager);
            delete(obj.ToolstripTabManager);
            delete(obj.DataAcquisitionManager);
            delete(obj.CircularBuffer);
            delete(obj.Mediator);
        end
        
        function requestHardwareManagerToDestroyApp(obj, ~, ~)
            closeReason = matlab.hwmgr.internal.AppletClosingReason.AppError;
            obj.closeApplet(closeReason);
        end
        
        function okayToClose = canClose(obj, closeReason)
            % This method is invoked by Hardware manager before tearing
            % down the App.
            
            if ~isempty(obj.AppStateManager)
                okayToClose = obj.AppStateManager.isOkayToClose;
            else
                % Set 'okayToClose' to true, if canClose method is invoked
                % by HardwareManager before the 'init' and 'construct'
                % phase is complete.
                okayToClose = true;
            end
            
            if ~okayToClose
                if strcmpi(obj.AppStateManager.Mode, 'Preview')
                    
                    switch closeReason
                        case {'AppClosing', 'CloseRunningApplet'}
                            warningStr = getString(message('daqaiapplet:DAQAIApplet:MainWindowClosingWarningDirtyPreviewMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_CloseOptionText'));
                        case 'RefreshHardware'
                            warningStr = getString(message('daqaiapplet:DAQAIApplet:RefreshDevicesWarningDirtyPreviewMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_RefreshOptionText'));
                        case 'DeviceChange'
                            warningStr = getString(message('daqaiapplet:DAQAIApplet:DeviceChangeWarningDirtyPreviewMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_CloseOptionText'));
                        otherwise
                            assert(false, 'Unknown app closing reason!');
                    end
                    
                elseif strcmpi(obj.AppStateManager.Mode, 'Recording')
                    
                    if obj.AppStateManager.DirtyState
                        switch closeReason
                            case {'AppClosing', 'CloseRunningApplet'}
                                warningStr = getString(message('daqaiapplet:DAQAIApplet:MainWindowClosingWarningDirtyRecordingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                                actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_CloseOptionText'));
                            case 'RefreshHardware'
                                warningStr = getString(message('daqaiapplet:DAQAIApplet:RefreshDevicesWarningDirtyRecordingMode', obj.DeviceInfo.FriendlyName));
                                actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_RefreshOptionText'));
                            case 'DeviceChange'
                                warningStr = getString(message('daqaiapplet:DAQAIApplet:DeviceChangeWarningDirtyRecordingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                                actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_CloseOptionText'));
                            otherwise
                                assert(false, 'Unknown app closing reason!');
                        end
                        
                    else
                        switch closeReason
                            case {'AppClosing', 'CloseRunningApplet'}
                                warningStr = getString(message('daqaiapplet:DAQAIApplet:MainWindowClosingWarningNonDirtyRecordingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                                actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_CloseOptionText'));
                            case 'RefreshHardware'
                                warningStr = getString(message('daqaiapplet:DAQAIApplet:RefreshDevicesWarningNonDirtyRecordingMode', obj.DeviceInfo.FriendlyName));
                                actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_RefreshOptionText'));
                            case 'DeviceChange'
                                warningStr = getString(message('daqaiapplet:DAQAIApplet:DeviceChangeWarningNonDirtyRecordingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                                actionOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_CloseOptionText'));
                            otherwise
                                assert(false, 'Unknown app closing reason!');
                        end
                    end
                    
                end
                
                cancelOptionText = getString(message('daqaiapplet:DAQAIApplet:OptionDialog_CancelOptionText'));
                
                % Display appropriate warning message to the user
                selection = obj.showConfirm(obj.DisplayName, warningStr,...
                    {actionOptionText, cancelOptionText}, cancelOptionText);
                result = strcmp(selection, actionOptionText);
                
                if result == 1
                    okayToClose = true;
                    obj.AppStateManager.handleAppClose();
                end
            end
        end
             
        function requestErrorDialog(obj, errorInfo)
            obj.showError(errorInfo.Title, errorInfo.Message);
        end
        
        function requestWarningDialog(obj, warningInfo)
            obj.showWarning(warningInfo.Title, warningInfo.Message);
        end

        function requestConfirmationDialog(obj, dialogArguments)
            % Display confirmation dialog and wait for result
            result = obj.showConfirm(dialogArguments.Title,...
                dialogArguments.WarningStr, dialogArguments.Options,...
                dialogArguments.DefaultOption);

            % Pass result to DialogDisplayManager to be published to
            % requesting module
            obj.DialogDisplayManager.setDialogResult(result);
        end
        
        function icon = getIcon(obj)
            icon = matlab.ui.internal.toolstrip.Icon(obj.AppletIconSource);
        end
        
        function daqObj = getDaqObj(obj)
            daqObj = obj.DataAcquisitionManager.DaqObj;
        end
    end
    
    methods(Static)
        function  supportFlag = isDeviceSupported(device)
            % This method is here for future use. Dependency on Hardware
            % Manager.
            supportFlag = true;
        end
    end
end

classdef DAQAOApplet < matlab.hwmgr.internal.AppletBase
    %DAQAOAPPLET - Main class for the Analog Output Generator (AOG)

    %   This class defines the initialization, construction, running and
    %   destruction of the Analog Output Generator (AOG), which is
    %   orchestrated by the Hardware Manager's Plugin Manager Module.
    
    % Copyright 2018-2022 The MathWorks, Inc.
    
    properties(Access = private)    
        AppTeardownRequestListener
        ErrorRequestListener
        
        Mediator
        DataAcquisitionManager
        WorkspaceManager
        ToolstripTabManager
        AppletSpaceManager
        ErrorDisplayManager
        AppStateManager
        GenerateScriptManager
    end
    
    properties(Constant)
        DisplayName = getString(message('daqaoapplet:DAQAOApplet:AppletTitle'))
        AppletIconSource = fullfile(matlabroot,...
            'toolbox', 'daq', 'apps', 'daqaoapplet', 'icons', 'analogOutputGenerator_24.png')

        LicenseRequiredErrorID = "daqappletshared:DAQAppletShared:DAQLicenseRequired"
        LicenseRequiredErrorMsg = message(daqaoapplet.applet.DAQAOApplet.LicenseRequiredErrorID,...
            daqaoapplet.applet.DAQAOApplet.DisplayName).string
    end
    
    methods
        function obj = DAQAOApplet()
            try
                daq.Session.checkLicense();
            catch ex
                throw(MException(daqaoapplet.applet.DAQAOApplet.LicenseRequiredErrorID, ...
                    daqaoapplet.applet.DAQAOApplet.LicenseRequiredErrorMsg));
            end
        end

        function init(obj, hwmgrHandles)
            init@matlab.hwmgr.internal.AppletBase(obj, hwmgrHandles)
            
            % Create Mediator
            obj.Mediator = matlabshared.mediator.internal.Mediator;
            
            % Create the Toolstrip Tab Manager
            obj.ToolstripTabManager = daqaoapplet.applet.modules.ToolstripTabManager(...
                obj.Mediator, obj.ToolstripTabHandle);
            
            % Create the Applet Space Manager
            obj.AppletSpaceManager = daqaoapplet.applet.modules.AppletSpaceManager(...
                obj.Mediator, hwmgrHandles);

            % Creat the Workspace Manager
            obj.WorkspaceManager = daqaoapplet.applet.modules.WorkspaceManager(...
                obj.Mediator);
            
            % Create the Data Acquisition Manager
            obj.DataAcquisitionManager = daqaoapplet.applet.modules.DataAcquisitionManager(...
                obj.Mediator, obj.DeviceInfo);
            
            % Create the Error Display Manager
            obj.ErrorDisplayManager = daqapplet.shared.modules.ErrorDisplayManager(...
                obj.Mediator, obj.DisplayName);
            obj.ErrorRequestListener = obj.ErrorDisplayManager.listener('ErrorInfo',...
                'PostSet', @(src,event)obj.requestErrorDialog(event.AffectedObject.ErrorInfo));
            
            % Create the App State Manager
            obj.AppStateManager = daqaoapplet.applet.modules.AppStateManager(obj.Mediator);
            % Listen to 'RequestHardwareManagerToDestroyApp' for requesting
            % hardware manager to teardown the applet
            obj.AppTeardownRequestListener = obj.AppStateManager.listener(...
                'RequestHardwareManagerToDestroyApp',...
                'PostSet', @obj.requestHardwareManagerToDestroyApp);
            
            % Create the Script Generator Manager
            obj.GenerateScriptManager = daqaoapplet.applet.modules.GenerateScriptManager(...
                obj.Mediator, obj.DeviceInfo);
        end
        
        function construct(obj)
            % Initialization of all the modules (if required) should happen
            % during 'construct' phase. The very first step in this method
            % should be to turn on the 'mediator', this shall connect all
            % the modules.
            
            obj.Mediator.connect();
            
            % Initialize Data Acquisition Manager
            obj.DataAcquisitionManager.initialize();
            
            % Initialize Applet Space Manager
            obj.AppletSpaceManager.initialize();
            
            % Initialize Workspace Manager
            obj.WorkspaceManager.initialize();
                        
            % Initialize Script Generator Manager
            obj.GenerateScriptManager.initialize();
            
            % Initialize Toolstrip Tab Manager
            obj.ToolstripTabManager.initialize();
        end
        
        function run(obj)
                        
            % Stop the interval timer in the AppletSpaceManager and enable
            % the attached listener. Refer to geck g1883213.
            obj.AppletSpaceManager.stopTimerAndEnableListener();
        end
        
        function destroy(obj)
            obj.Mediator.disconnect();
            
            % Delete listener
            delete(obj.AppTeardownRequestListener);
            
            % Delete all modules
            delete(obj.GenerateScriptManager);
            delete(obj.AppStateManager);
            delete(obj.ErrorDisplayManager);
            delete(obj.DataAcquisitionManager);
            delete(obj.WorkspaceManager);
            delete(obj.AppletSpaceManager);
            delete(obj.ToolstripTabManager);
            delete(obj.Mediator);
        end
                
        function requestHardwareManagerToDestroyApp(obj, ~, ~)
            closeReason = matlab.hwmgr.internal.AppletClosingReason.AppError;
            obj.closeApplet(closeReason);
        end
        
        function okayToClose = canClose(obj, closeReason)
            % This method is invoked by Hardware manager before tearing
            % down the App.
            
            okayToClose = true;
            if ~isempty(obj.AppStateManager)
                okayToClose = obj.AppStateManager.isOkayToClose();                
            end
            
            if okayToClose
                return
            end
            
            if strcmpi(obj.AppStateManager.Mode, 'Preview')
                
                switch closeReason
                    case {'AppClosing', 'CloseRunningApplet'}
                        warningStr = getString(message('daqaoapplet:DAQAOApplet:MainWindowClosingWarningDirtyPreviewMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                        actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_CloseOptionText'));
                    case 'RefreshHardware'
                        warningStr = getString(message('daqaoapplet:DAQAOApplet:RefreshDevicesWarningDirtyPreviewMode', obj.DeviceInfo.FriendlyName));
                        actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_RefreshOptionText'));
                    case 'DeviceChange'
                        warningStr = getString(message('daqaoapplet:DAQAOApplet:DeviceChangeWarningDirtyPreviewMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                        actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_CloseOptionText'));
                    otherwise
                        assert(false, 'Unknown app closing reason!');
                end
                
            elseif strcmpi(obj.AppStateManager.Mode, 'Generating')
                
                if obj.AppStateManager.DirtyState
                    switch closeReason
                        case {'AppClosing', 'CloseRunningApplet'}
                            warningStr = getString(message('daqaoapplet:DAQAOApplet:MainWindowClosingWarningDirtyGeneratingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_CloseOptionText'));
                        case 'RefreshHardware'
                            warningStr = getString(message('daqaoapplet:DAQAOApplet:RefreshDevicesWarningDirtyGeneratingMode', obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_RefreshOptionText'));
                        case 'DeviceChange'
                            warningStr = getString(message('daqaoapplet:DAQAOApplet:DeviceChangeWarningDirtyGeneratingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_CloseOptionText'));
                        otherwise
                            assert(false, 'Unknown app closing reason!');
                    end
                    
                else
                    switch closeReason
                        case {'AppClosing', 'CloseRunningApplet'}
                            warningStr = getString(message('daqaoapplet:DAQAOApplet:MainWindowClosingWarningNonDirtyGeneratingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_CloseOptionText'));
                        case 'RefreshHardware'
                            warningStr = getString(message('daqaoapplet:DAQAOApplet:RefreshDevicesWarningNonDirtyGeneratingMode', obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_RefreshOptionText'));
                        case 'DeviceChange'
                            warningStr = getString(message('daqaoapplet:DAQAOApplet:DeviceChangeWarningNonDirtyGeneratingMode', obj.DisplayName, obj.DeviceInfo.FriendlyName));
                            actionOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_CloseOptionText'));
                        otherwise
                            assert(false, 'Unknown app closing reason!');
                    end
                end
                
            end

            cancelOptionText = getString(message('daqaoapplet:DAQAOApplet:OptionDialog_CancelOptionText'));
            
            % Display appropriate warning message to the user
            result = obj.showConfirm(obj.DisplayName, warningStr,...
                {actionOptionText, cancelOptionText},...
                cancelOptionText);
            result = strcmp(result, actionOptionText);
            
            if result == 1
                okayToClose = true;
                obj.AppStateManager.handleAppClose();
            end
        end
        
        function requestErrorDialog(obj, errorInfo)
            obj.showError(errorInfo.Title, errorInfo.Message);
        end
        
        function icon = getIcon(obj)
            icon = matlab.ui.internal.toolstrip.Icon(obj.AppletIconSource);
        end
        
        function daqObj = getDaqObj(obj)
            daqObj = obj.DataAcquisitionManager.DaqObj;
        end
    end
    
    methods(Static)
        function supportFlag = isDeviceSupported(device)
            % This method is here for future use. Dependency on Hardware
            % Manager.
            supportFlag = true;
        end
    end
end

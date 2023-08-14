classdef BrowserService<matlab.internal.profileviewer.ImplManagerClient




    properties(Access=private,Constant)
        RELEASE_URL='toolbox/matlab/profileviewer/index.html?websocket=on&id='
        DEBUG_URL='toolbox/matlab/profileviewer/index-debug.html?websocket=on&id='
        DEFAULT_WINDOW_WIDTH=950
        DEFAULT_WINDOW_HEIGHT=600
        WINDOW_TITLE_BAR_HEIGHT=22
    end

    properties(SetAccess=private,Hidden)
ClientId
ProfilerURL
ProfilerWindow
ProfileInterface
        IsDebugMode=false
        IsWindowMaximized=false
    end

    methods(Access=protected)
        function onImplSwapIn(obj)
            obj.ProfileInterface=obj.ImplManagerInstance.getProfileInterfaceImpl();
        end

        function onClientRegistration(obj)
            obj.ProfileInterface=obj.ImplManagerInstance.getProfileInterfaceImpl();
        end
    end

    methods(Hidden)
        function obj=BrowserService(clientId,implManager)
            obj@matlab.internal.profileviewer.ImplManagerClient(implManager);
            obj.ClientId=clientId;
            mlock;
        end

        function status=isProfilerWindowValid(obj)

            status=~isempty(obj.ProfilerWindow)&&isvalid(obj.ProfilerWindow)&&obj.ProfilerWindow.isWindowValid;
        end

        function status=getProfileViewerWindow(obj)


            if obj.isProfilerWindowValid
                obj.ProfilerWindow.bringToFront();
                status=false;
                return;
            end


            windowPosition=obj.getPreviousWindowPosition();
            obj.ProfilerURL=obj.getProfilerURL;
            remoteDebuggingPort=matlab.internal.getDebugPort;
            obj.ProfilerWindow=matlab.internal.webwindow(obj.ProfilerURL,remoteDebuggingPort,'Position',windowPosition);
            obj.ProfilerWindow.CustomWindowClosingCallback=@obj.handleWindowClosingEvent;
            obj.ProfilerWindow.MATLABClosingCallback=@obj.handleMATLABClosingEvent;
            obj.ProfilerWindow.CustomWindowResizingCallback=@obj.handleWindowResizingEvent;
            obj.ProfilerWindow.Title=getString(message('MATLAB:profiler:Tool_profiler_Label'));


            obj.ProfilerWindow.bringToFront();
            s=settings;
            if s.matlab.profiler.window.IsMaximized.hasPersonalValue&&s.matlab.profiler.window.IsMaximized.PersonalValue
                obj.ProfilerWindow.maximize();
            end

            if obj.IsDebugMode
                obj.printCEFDebugInformation;
            end
            status=true;
        end

        function bringToFrontIfOpen(obj)
            if obj.isProfilerWindowValid
                getProfileViewerWindow(obj);
            end
        end

        function close(obj)
            delete(obj.ProfilerWindow);
            obj.ProfilerWindow=[];
        end

        function setDebugMode(obj,debugMode)
            obj.IsDebugMode=debugMode;
        end
    end

    methods(Access=protected)
        function profilerURL=getProfilerURL(obj)
            isJSD=~matlab.internal.lang.capability.Capability.isSupported(matlab.internal.lang.capability.Capability.LocalClient)||feature('webui');

            if obj.IsDebugMode
                profilerURL=obj.DEBUG_URL;
            else
                profilerURL=obj.RELEASE_URL;
            end
            profilerURL=connector.getUrl([profilerURL,obj.ClientId,'&isJSD=',num2str(isJSD)]);
        end

        function printCEFDebugInformation(obj)

            remotePort=obj.ProfilerWindow.RemoteDebuggingPort;
            remoteDebugURL=['http://localhost:',num2str(remotePort),'/'];
            webCommand=sprintf('web(''%s'',''-browser'')',remoteDebugURL);
            fprintf('\n    CEF Remote Debug URL: %s\n',remoteDebugURL);
            fprintf('\n    <a href="matlab: %s">Click here to debug CEF using your system browser</a>\n\n',webCommand);
        end

        function windowPosition=getPreviousWindowPosition(obj)
            s=settings;
            if s.matlab.profiler.window.Position.hasPersonalValue
                windowPosition=s.matlab.profiler.window.Position.PersonalValue;
            else
                windowPosition=obj.getDefaultPosition;
            end
            windowPosition=matlab.internal.profileviewer.EnsureWindowPositionOnScreen(windowPosition);
        end

        function windowPosition=getDefaultPosition(obj)

            oldUnits=get(groot,'Units');
            set(groot,'Units','pixels');
            screenSize=get(groot,'ScreenSize');
            set(groot,'Units',oldUnits);
            screenWidth=screenSize(3);
            screenHeight=screenSize(4);
            xPosition=(screenWidth-obj.DEFAULT_WINDOW_WIDTH)/2;
            yPosition=(screenHeight-obj.DEFAULT_WINDOW_HEIGHT-obj.WINDOW_TITLE_BAR_HEIGHT)/2;
            windowPosition=[xPosition,yPosition,obj.DEFAULT_WINDOW_WIDTH,obj.DEFAULT_WINDOW_HEIGHT];
        end

        function handleWindowClosingEvent(obj,~,~)

            for profileInterface=values(obj.ImplManagerInstance.getAllProfileInterfaceImpl)
                if strcmp(profileInterface{1}.getProfilerStatus(),'on')
                    profileInterface{1}.turnOff();
                end
            end
            obj.saveWindowStateInSettings;
            obj.ProfilerWindow.close();
        end

        function handleMATLABClosingEvent(obj,~,~)
            obj.saveWindowStateInSettings;
            obj.ProfilerWindow.close();
            exit;
        end

        function saveWindowStateInSettings(obj)
            s=settings;
            s.matlab.profiler.window.Position.PersonalValue=obj.ProfilerWindow.Position;
            s.matlab.profiler.window.IsMaximized.PersonalValue=obj.IsWindowMaximized;
        end

        function handleWindowResizingEvent(obj,~,~)
            if obj.ProfilerWindow.isMaximized()
                obj.IsWindowMaximized=true;
            else
                obj.IsWindowMaximized=false;
            end
        end
    end
end

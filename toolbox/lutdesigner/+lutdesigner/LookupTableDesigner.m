classdef LookupTableDesigner<lutdesigner.service.RemotableObject

    properties(SetAccess=private)
MessageService
LookupTableFinder
Navigator
Explorer
EditorManager
Reporter
Window
    end

    methods(Access=private)
        function this=LookupTableDesigner
            start_simulink;
            connector.ensureServiceOn();
            this.MessageService=message.internal.MessageService('LookupTableDesigner');
            this.LookupTableFinder=lutdesigner.lutfinder.LookupTableFinder.getInstance();

            this.Navigator=lutdesigner.navigator.Navigator(this.LookupTableFinder);
            this.Explorer=lutdesigner.explorer.Explorer(this.LookupTableFinder);
            this.EditorManager=lutdesigner.editor.EditorManager();
            this.Reporter=lutdesigner.report.Reporter(this.LookupTableFinder);
        end
    end

    methods
        function delete(this)
            if this.isOpened()
                this.Window.delete();
            end

            this.Reporter.delete();
            this.EditorManager.delete();
            this.Explorer.delete();
            this.Navigator.delete();
            this.LookupTableFinder.delete();
            this.MessageService.delete();
        end

        function id=getNavigatorRemoteID(this)
            id=this.Navigator.RemoteID;
        end

        function id=getExplorerRemoteID(this)
            id=this.Explorer.RemoteID;
        end

        function id=getEditorManagerRemoteID(this)
            id=this.EditorManager.RemoteID;
        end

        function id=getReporterRemoteID(this)
            id=this.Reporter.RemoteID;
        end

        function tf=isOpened(this)
            tf=~isempty(this.Window)&&isvalid(this.Window)&&this.Window.isWindowValid();
        end

        function open(this)
            if this.isOpened()
                if this.Window.isFocused
                    this.refresh();
                else
                    this.Window.bringToFront();
                end
            else
                if this.debug()
                    htmlPath='toolbox/lutdesigner/index-debug.html';
                else
                    htmlPath='toolbox/lutdesigner/index.html';
                end
                url=[connector.getUrl(htmlPath),'&remoteID=',this.RemoteID];

                [defaultWindowPosition,minimumWindowSize]=this.calculateWindowPositionSettings(get(0,'screensize'));
                window=matlab.internal.webwindow(url,...
                'DebugPort',matlab.internal.getDebugPort(),...
                'Origin','TopLeft',...
                'Position',defaultWindowPosition);
                window.CustomWindowClosingCallback=@(src,data)this.close();
                window.FocusGained=@(src,data)this.refresh();
                window.Tag='LookupTableDesigner';
                window.Title=getString(message('lutdesigner:messages:LUTDesignerTitle'));
                window.Icon=fullfile(matlabroot,'toolbox','lutdesigner','resources','lookupTableEditor_16.png');
                window.setMinSize(minimumWindowSize);
                this.Window=window;

                if this.debug()
                    this.openDevTools();
                    this.Window.bringToFront();
                end
            end
        end

        function close(this)





            delete(this);
        end

        function refresh(this)
            this.MessageService.publish('/LookupTableDesigner/Notification/BackendChange',struct);
        end

        function setContext(this,context)
            import lutdesigner.access.Access
            import lutdesigner.lutfinder.LookupTableFinder

            if isvarname(context)&&~bdIsLoaded(context)
                load_system(context);
            end

            contextAccess=lutdesigner.access.Access.fromSimulinkComponent(context);
            this.Explorer.setFocusAccess(contextAccess.toDesc());
        end

        function launchHelp(~)
            helpview('simulink','lookup_table_editor');
        end
    end

    methods(Hidden)
        function openDevTools(this)
            assert(this.isOpened());
            this.Window.executeJS('cefclient.sendMessage("openDevTools");');
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent instance
            if isempty(instance)||~instance.isvalid()
                instance=lutdesigner.LookupTableDesigner;
            end
            obj=instance;
        end
    end

    methods(Static,Hidden)
        function[defaultWindowPosition,minimumWindowSize]=calculateWindowPositionSettings(screenPosition)
            screenWidth=screenPosition(3);
            screenHeight=screenPosition(4);

            offsetX=0.05*screenWidth;
            offsetY=0.05*screenHeight;
            maxProperWidth=0.9*screenWidth;
            maxProperHeight=0.9*screenHeight;
            preferredWidth=1200;
            preferredMinWidth=500;
            preferredHeight=800;
            preferredMinHeight=500;

            windowWidth=min(preferredWidth,maxProperWidth);
            windowHeight=min(preferredHeight,maxProperHeight);

            minWindowWidth=min(preferredMinWidth,maxProperWidth);
            minWindowHeight=min(preferredMinHeight,maxProperHeight);

            defaultWindowPosition=[offsetX,offsetY,windowWidth,windowHeight];
            minimumWindowSize=[minWindowWidth,minWindowHeight];
        end

        function prevState=debug(newState)
            persistent isDebug
            if isempty(isDebug)
                isDebug=false;
            end

            prevState=isDebug;

            if exist('newState','var')
                isDebug=matlab.internal.getDebugPort()>0&&newState;
            end
        end
    end
end

classdef UiWindow<handle

    properties(Constant,Hidden)
        REL_URL='toolbox/dashboard/ui/web/index.html';
        DEBUG_URL='toolbox/dashboard/ui/web/index-debug.html';
        READY_TO_SHOW_CHANNEL='ReadyToShow';
    end


    properties(SetAccess=private)
        SessionID='';
        WindowID='';
        ProjectPath='';
    end


    properties(Hidden)
        Window;
        CloseCallback;
        ReadyToShowSubscription;
        OpenInBrowser='';
        IsOpen=false;
        InternalService;
    end


    methods

        function this=UiWindow(session,onCloseCallback)
            this.SessionID=session;
            this.CloseCallback=onCloseCallback;

            dashboard.internal.initializeOnce();
            this.InternalService=alm.internal.UiService(session);
        end


        function open(this,varargin)
            ip=inputParser();
            ip.addParameter('Artifact','',@metric.dashboard.Verify.ScalarCharOrString);
            ip.addParameter('Project','',@metric.dashboard.Verify.ScalarCharOrString);
            ip.addParameter('Class','',@metric.dashboard.Verify.ScalarCharOrString);
            ip.addParameter('LayoutId','',@metric.dashboard.Verify.ScalarCharOrString);

            ip.parse(varargin{:});
            artifactIn=char(ip.Results.Artifact);
            classIn=char(ip.Results.Class);
            projIn=char(ip.Results.Project);
            layoutId=char(ip.Results.LayoutId);

            if~this.isOpen()
                if isempty(projIn)
                    projIn=dashboard.internal.ProjectController.getCurrentProject();
                    projIn=projIn.Path;
                end
                urlToOpen=this.buildURL(artifactIn,classIn,projIn,layoutId);
                hits=regexp(urlToOpen,'snc\=([a-zA-Z0-9]+)','tokens');

                if isempty(hits)
                    hits=regexp(urlToOpen,'session\=([a-zA-Z0-9\-]+)','tokens');
                end
                this.WindowID=hits{1}{1};

                switch this.browserMode()
                case 'CEF'
                    title=getString(message('dashboard:ModelTestingDashboard:DashboardTitle'));
                    useCEF=true;
                    debugMode=dashboard.UiWindow.debugMode();


                    geo=this.getGeometry();

                    browserWindow=Simulink.HMI.BrowserDlg(...
                    urlToOpen,title,geo,...
                    [],useCEF,debugMode,...
                    @()onBrowserClose(this),...
                    true);
                    browserWindow.CEFWindow.setMinSize([
                    min(geo(3),576),...
                    min(geo(4),576)]);

                    this.Window=browserWindow;
                case 'Chrome'

                    profilePath=strcat(tempdir(),'dashboard-ui-remote-profile');
                    system(['start chrome --remote-debugging-port=9222 --user-data-dir="',profilePath,'" "',urlToOpen,'"']);
                    this.Window='Chrome';
                otherwise

                    this.Window=this.browserMode();
                    disp(urlToOpen);
                end

                this.OpenInBrowser=this.browserMode();
                this.IsOpen=true;
            else


                if isempty(artifactIn)
                    this.InternalService.executeAction(...
                    'dashboard::SwitchToLayoutAction',...
                    '',...
                    this.SessionID,...
                    0,...
                    jsonencode({layoutId})...
                    );
                else

                    this.InternalService.executeAction(...
                    'dashboard::ShowDashboardAction',...
                    '',...
                    this.SessionID,...
                    0,...
                    jsonencode({artifactIn,true,layoutId})...
                    );
                end
            end
            this.bringToFront();
        end


        function setProjectPath(this,projectPath)
            this.ProjectPath=projectPath;
            this.InternalService.setProjectPath(projectPath);
        end


        function state=isOpen(this)
            if~isa(this.Window,'Simulink.HMI.BrowserDlg')||~this.Window.isvalid
                this.IsOpen=false;
            end

            state=this.IsOpen;
        end


        function bringToFront(this)
            if this.isOpen()
                this.Window.bringToFront();
            end
        end


        function close(this)
            this.CloseCallback(this);
            if this.isOpen()
                this.Window.delete();
                this.Window=[];
            end
        end


        function delete(this)
            this.close();
        end
    end


    methods

        function ret=getGeometry(this)%#ok<MANU>
            width=1400;
            height=1000;

            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=0.8*screenWidth;
            maxHeight=0.9*screenHeight;
            if maxWidth>0&&width>maxWidth
                width=maxWidth;
            end
            if maxHeight>0&&height>maxHeight
                height=maxHeight;
            end

            xOffset=(screenWidth-width)/2;
            yOffset=(screenHeight-height)/2;

            ret=[xOffset,yOffset,width,height];
        end

    end



    methods(Hidden)

        function url=buildURL(this,artifactIn,classIn,projIn,layoutId)
            cAPI=dashboard.internal.ConnectorAPI.getAPI();

            if dashboard.UiWindow.debugMode()
                url=cAPI.getURL(dashboard.UiWindow.DEBUG_URL);
            else
                url=cAPI.getURL(dashboard.UiWindow.REL_URL);
            end

            currentLocale=matlab.internal.i18n.locale.default;

            dashboard.UiWindow.feature('UseStaticThresholdConfig',~feature('ALMThresholdService'));
            features=dashboard.UiWindow.feature;
            features=[fieldnames(features),struct2cell(features)];
            features=features';

            localClient=matlab.internal.lang.capability.Capability.isSupported(matlab.internal.lang.capability.Capability.LocalClient);
            if localClient
                localClient='on';
            else
                localClient='off';
            end
            uri=matlab.net.URI(url,'session',this.SessionID,...
            'artifact',artifactIn,...
            'class',classIn,...
            'project',projIn,...
            'loc',currentLocale.Ctype,...
            'websocket','on',...
            'localClient',localClient,...
            'layoutId',layoutId,...
            features{:});

            url=char(uri.EncodedURI);

        end


        function onBrowserClose(this)
            this.CloseCallback(this);
            this.IsOpen=false;
            this.Window=[];
        end


        function cppUIService=getCPPUiService(this)
            cppUIService=this.InternalService;
        end
    end


    methods(Hidden,Static)

        function features=feature(name,state)
            persistent fts
            if isempty(fts)
                fts=struct();
            end
            if nargin>1

                if(state)
                    fts.(name)='on';
                else
                    fts.(name)='off';
                end
            end
            features=fts;
        end


        function id=generateWindowSessionId()
            id=matlab.lang.internal.uuid;
        end


        function isDebug=debugMode(varargin)

            persistent IsDebug;

            if nargin>0
                IsDebug=varargin{1};
            elseif isempty(IsDebug)
                IsDebug=false;
            end

            isDebug=IsDebug;
        end



        function out=httpsProtocol(varargin)

            persistent UseHttps;

            if nargin>0
                UseHttps=varargin{1};
            elseif isempty(UseHttps)
                UseHttps=true;
            end

            out=UseHttps;
        end



        function browser=browserMode(varargin)

            persistent Browser;

            if nargin>0
                b=varargin{1};

                if strcmpi(b,'cef')
                    Browser='CEF';
                elseif strcmpi(b,'chrome')
                    Browser='Chrome';
                elseif strcmpi(b,'none')
                    Browser='None';
                end
            elseif isempty(Browser)
                Browser='CEF';
            end

            browser=Browser;
        end
    end
end
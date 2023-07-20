classdef Explorer<handle






    properties(Constant,Hidden)
        REL_URL='toolbox/slcheck/slmetrics_mmt/mmt/index.html';
        DEBUG_URL='toolbox/slcheck/slmetrics_mmt/mmt/index-debug.html';
        READY_TO_SHOW_CHANNEL='ReadyToShow';
    end




    properties(SetAccess=private)
        ID='';
    end




    properties(Access=private)
        Window;
        ReadyToShowSubscription;
        OpenInBrowser='';
        IsOpen=false;
        IExplorer;
        URL='';
    end




    properties(Access=public)
        model='';
        type='';
    end




    events(Hidden)



        ReadyToShow;
    end




    methods



        function open(this,model,type)

            if~this.isOpen()

                this.createSession(model,type);

                switch this.browserMode()
                case 'CEF'
                    title=DAStudio.message('slcheck:mmt:Title');
                    useCEF=true;
                    debugMode=slmetric.Explorer.debugMode();




                    geo=this.getGeometry();

                    browserWindow=Simulink.HMI.BrowserDlg(...
                    this.URL,title,geo,...
                    [],useCEF,debugMode,...
                    @()onBrowserClose(this),...
                    true);

                    this.Window=browserWindow;
                case 'Chrome'


                    system(['start chrome "',this.URL,'"']);
                    this.Window='Chrome';
                otherwise

                    this.Window=this.browserMode();
                    disp(this.URL);
                end

                this.OpenInBrowser=this.browserMode();
            else
                this.bringToFront();
            end
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

            if this.isOpen()
                this.Window.delete();
                this.Window=[];






                m=slmetric.internal.mmt.Manager.get();
                m.unregister(this.ID);

                this.destroySession();
            end
        end

        function delete(this)

            this.close();

            if isa(this.IExplorer,'slmetric.internal.Explorer')
                this.IExplorer.delete();
            end
        end
    end




    methods(Access=private)
        function createSession(this,model,type)
            this.model=model;
            this.type=type;

            cAPI=slmetric.internal.mmt.ConnectorAPI.getAPI();
            if slmetric.Explorer.debugMode()
                url=cAPI.getURL(slmetric.Explorer.DEBUG_URL);
            else
                url=cAPI.getURL(slmetric.Explorer.REL_URL);
            end

            this.URL=url;


            this.ReadyToShowSubscription=...
            message.subscribe('/slmetric/c2s',@(msg)onReadyToShow(this,msg));


            hits=regexp(url,'snc\=([a-zA-Z0-9]+)','tokens');
            this.ID=hits{1}{1};


            this.IExplorer=slmetric.internal.Explorer(this.ID);



            m=slmetric.internal.mmt.Manager.get();
            m.register(this);
        end

        function destroySession(this)
            if isa(this.IExplorer,'slmetric.internal.Explorer')
                this.IExplorer.delete();
            end

            this.IExplorer=[];
            this.model='';
            this.type=[];
            this.URL='';
            this.ID='';
            this.ReadyToShowSubscription=[];
        end
    end

    methods


        function ret=getGeometry(this)%#ok<MANU>
            width=1080;
            height=845;

            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=0.8*screenWidth;
            maxHeight=0.8*screenHeight;
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

        function url=getURL(this)
            url=this.URL;
        end




        function onBrowserClose(this)

            this.IsOpen=false;
            this.Window=[];
            this.IExplorer.delete();
            this.IExplorer=[];
            m=slmetric.internal.mmt.Manager.get();
            m.unregister(this.ID);

            this.ID='';
            this.model='';
            this.type='';
            this.URL='';
        end

        function onReadyToShow(this,data)

            if isfield(data,'Message')&&...
                strcmp(data.Message,this.READY_TO_SHOW_CHANNEL)&&...
                strcmp(data.SessionID,this.ID)

                if isvalid(this)&&~isempty(this.Window)
                    if strcmp(this.OpenInBrowser,'CEF')

                        this.Window.show();
                    end
                end



                if strcmpi(this.type,'Subsystem')
                    this.IExplorer.setDataset(this.model,'Subsystem');
                else
                    this.IExplorer.setDataset(this.model,'Model');
                end


                message.unsubscribe(this.ReadyToShowSubscription);
                this.ReadyToShowSubscription=[];


                this.IsOpen=true;

                notify(this,'ReadyToShow');
            end
        end
    end





    methods(Hidden,Static)



        function isDebug=debugMode(varargin)
            mlock;
            persistent IsDebug;

            if nargin>0
                IsDebug=varargin{1};
            elseif isempty(IsDebug)
                IsDebug=false;
            end

            isDebug=IsDebug;
        end



        function out=httpsProtocol(varargin)
            mlock;
            persistent UseHttps;

            if nargin>0
                UseHttps=varargin{1};
            elseif isempty(UseHttps)
                UseHttps=true;
            end

            out=UseHttps;
        end






        function browser=browserMode(varargin)
            mlock;
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


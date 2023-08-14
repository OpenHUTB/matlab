classdef HTMLReport<handle



    properties(Constant,Hidden)
        REL_URL='toolbox/soc/complexity/app/compapp/index.html';
        DEBUG_URL='toolbox/soc/complexity/app/compapp/index-debug.html';
        tag='ComplexityAppDialog';

    end

    properties(SetAccess=private,Hidden)
        ID='';
    end

    properties(Access=private)
        Window;
        IsOpen=false;
        URL='';
        StatusSubscription;
        Results;
        Mode;
        TabTitle;
    end

    events(Hidden)



        ReadyToShow;
    end

    methods(Access=public)
        function obj=HTMLReport(results,mode,tab_title)
            obj.Results=results;
            obj.Mode=mode;
            obj.TabTitle=tab_title;
        end
        function open(this,varargin)
            if~this.isOpen()
                this.createSession(varargin);
                title=DAStudio.message('ComplexityApp:report:Title');
                useCEF=true;
                debugMode=soc.ui.HTMLReport.debugMode();
                geo=this.getGeometry();

                this.StatusSubscription=message.subscribe(strcat('/compapp/APP2ML/',this.ID,'/status'),@(data)this.handleMessagesFromApp(data));


                browserWindow=Simulink.HMI.BrowserDlg(...
                [this.URL,'&mode=',this.Mode,'&tabTitle=',this.TabTitle],title,geo,...
                [],useCEF,debugMode,...
                @()onBrowserClose(this),...
                true);
                this.Window=browserWindow;


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
                m=soc.ui.internal.Manager.get();
                m.unregister(this.ID);
                this.destroySession();
            end
        end

        function delete(this)
            this.close();
        end
    end

    methods(Access=private)
        function createSession(this,varargin)

            cAPI=soc.ui.internal.ConnectorAPI.getAPI();
            if soc.ui.HTMLReport.debugMode()
                url=cAPI.getURL(soc.ui.HTMLReport.DEBUG_URL);
            else
                url=cAPI.getURL(soc.ui.HTMLReport.REL_URL);
            end

            this.URL=url;


            hits=regexp(url,'snc\=([a-zA-Z0-9]+)','tokens');
            this.ID=hits{1}{1};




            m=soc.ui.internal.Manager.get();
            m.register(this);
        end

        function destroySession(this)
            this.URL='';
            this.ID='';
        end

        function handleMessagesFromApp(this,data)
            if isfield(data,'Message')&&...
                strcmp(data.Message,'started')&&...
                strcmp(data.SessionID,this.ID)

                if isvalid(this)&&~isempty(this.Window)


                    this.Window.show();

                end


                this.IsOpen=true;
                this.publishResults();
                notify(this,'ReadyToShow');
            end

        end
    end

    methods(Hidden)


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

        function url=getURL(this)
            url=this.URL;
        end

        function onBrowserClose(this)

            this.IsOpen=false;
            this.Window=[];
            m=soc.ui.internal.Manager.get();
            m.unregister(this.ID);

            this.ID='';
            this.URL='';
        end

        function publishResults(this)
            message.publish(strcat('/compapp/ML2APP/',this.ID,'/results'),this.Results);
        end
    end

    methods(Hidden,Static)


        function isDebug=debugMode(varargin)

            persistent IsDebug;

            if nargin>0
                IsDebug=varargin{1};
            elseif isempty(IsDebug)
                IsDebug=false;
            end

            isDebug=IsDebug;
        end


    end


end
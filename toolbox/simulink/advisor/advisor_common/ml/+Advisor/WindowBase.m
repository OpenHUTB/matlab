classdef WindowBase<handle




    properties(Abstract,Hidden)
        REL_URL;
        DEBUG_URL;
    end

    properties(Abstract,Access=public)
        App;
        ID;
    end

    properties(Access=public)
        Window;
        IsOpen=false;
        URL='';
        WindowTitle;
        isInitiated=false;
        bShowGUI=true;
    end

    methods(Abstract,Access=public)
        qStruct=defineURLQueryStruct(this);
        createSession(this,varargin);
        destroySession(this,varargin);
        size=defineWindowSize(this);
    end

    methods(Access=public)
        function this=WindowBase(varargin)

        end

        function delete(this)
            this.close();
        end

        function initiate(this,varargin)
            if~this.isInitiated
                this.initUrl();
                this.createSession(varargin{:});
                this.isInitiated=true;
            end
        end

        function open(this,varargin)
            if~this.isOpen()
                if nargin>1
                    this.bShowGUI=varargin{1};
                else
                    this.bShowGUI=true;
                end

                this.initiate(varargin{2:end});

                if this.bShowGUI
                    switch this.browserMode()
                    case 'CEF'
                        useCEF=true;
                        debugMode=this.debugMode();

                        sizeData=this.defineWindowSize();

                        browserWindow=Simulink.HMI.BrowserDlg(...
                        this.URL,this.WindowTitle,sizeData.size,...
                        [],useCEF,debugMode,...
                        @()this.close(),...
                        true);

                        this.Window=browserWindow;
                        this.Window.CEFWindow.setMinSize(sizeData.minSize);

                    case 'Chrome'


                        system(['start chrome "',this.URL,'"']);
                        this.Window='Chrome';
                    otherwise

                        this.Window=[];
                    end
                end
            else
                this.show();
            end
            this.bringToFront();
        end


        function state=isOpen(this)
            if strcmp(this.browserMode(),'CEF')
                this.IsOpen=isa(this.Window,'Simulink.HMI.BrowserDlg')&&this.Window.isvalid;
            else
                this.IsOpen=strcmp(this.Window,'Chrome');
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
                if~isempty(this.Window)
                    this.Window.delete();
                    this.Window=[];
                end
                this.destroySession();
                this.ID='';
                this.URL='';
            end
        end

        function url=getURL(this)
            url=this.URL;
        end

        function setWindowTitle(this,title)
            this.WindowTitle=title;
        end

        function setTitle(this,title)
            if isa(this.Window,'Simulink.HMI.BrowserDlg')&&this.Window.isvalid
                this.Window.setTitle(title);
            end
        end

        function title=getTitle(this)
            title='';
            if isa(this.Window,'Simulink.HMI.BrowserDlg')&&this.Window.isvalid
                title=this.Window.DlgTitle;
            end
        end

        function bResult=isValid(this)
            bResult=this.isInitiated;
        end

        function show(this)
            this.Window.show();
        end

        function hide(this)
            this.Window.hide();
        end

        function bVisible=isVisible(this)
            bVisible=false;
            if isa(this.Window,'Simulink.HMI.BrowserDlg')&&this.Window.isvalid
                bVisible=this.Window.CEFWindow.isVisible;
            end
        end
    end

    methods(Hidden)

        function initUrl(this)
            if this.debugMode()
                url=this.DEBUG_URL;
            else
                url=this.REL_URL;
            end

            qStruct=[];
            if strcmp(this.browserMode(),'CEF')
                qStruct.browsermode='CEF';
            end

            qStruct=this.defineURLQueryStruct();
            qStruct.websocket='on';

            connector.ensureServiceOn;
            url=connector.getUrl(url);
            uri=matlab.net.URI(url);
            uri.Query=matlab.net.QueryParameter(qStruct);

            url=char(uri.EncodedURI);
            url=connector.applyNonce(url);

            hits=regexp(url,'snc\=([a-zA-Z0-9]+)','tokens');
            if isempty(hits)
                this.ID=char(floor(9*rand(1,6))+65);
                url=[url,'&snc=',this.ID];
            else
                this.ID=hits{1}{1};
            end
            this.URL=url;
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



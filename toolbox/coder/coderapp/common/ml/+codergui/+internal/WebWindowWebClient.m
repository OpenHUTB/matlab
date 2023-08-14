


classdef(Sealed)WebWindowWebClient<codergui.WebClient


    properties(SetAccess=immutable)
Async
        SupportsEvalReturn=true
        SupportsKeepAlive=false
    end

    properties(SetAccess=immutable)
DebugPort
    end

    properties(SetAccess=private,Hidden)
Browser
    end

    properties(Access=private)
LoadedListener
    end

    methods
        function this=WebWindowWebClient(clientRoot,varargin)











            this=this@codergui.WebClient(clientRoot,varargin{:});

            ip=inputParser();
            ip.PartialMatching=false;
            ip.KeepUnmatched=true;
            ip.addParameter('Async',true,@islogical);

            ip.addParameter('DebugPort',matlab.internal.getDebugPort(),@(v)validateattributes(v,...
            {'double'},{'positive','integer'}));
            ip.parse(varargin{:});
            this.Async=ip.Results.Async&&~this.UseRemoteControl;

            this.DebugPort=ip.Results.DebugPort;



            this.LoadedListener=addlistener(this,'ClientLoaded',...
            'PostSet',@(varargin)this.updateWindowTitle());
        end
    end

    methods(Access=protected)
        function start(this)
            isMatlabOnline=codergui.internal.isMatlabOnline();
            if isMatlabOnline
                this.Browser=matlab.internal.webwindow(this.ClientUrl,this.DebugPort);
            else
                this.Browser=matlab.internal.webwindow(...
                this.ClientUrl,...
                this.DebugPort,...
                'Position',this.sizeToPosition(this.StoredWindowSize));
            end

            this.Browser.CustomWindowClosingCallback=@(varargin)this.close();
            this.Browser.MATLABWindowExitedCallback=this.Browser.CustomWindowClosingCallback;
            this.Browser.FocusGained=@(varargin)this.notify('WindowFocusGained');
            this.Browser.FocusLost=@(varargin)this.notify('WindowFocusLost');

            if isMatlabOnline

                this.Browser.show();
            end
        end

        function cleanup(this)
            this.Browser.delete();
            this.Browser=[];
            delete(this.LoadedListener);
            this.LoadedListener=[];
        end

        function setVisible(this,visible)
            if~this.Browser.isWindowValid
                return;
            end
            if visible
                this.Browser.show();
            else
                this.Browser.hide();
            end
        end

        function result=doJsEval(this,code)
            result=this.Browser.executeJS(code);
        end

        function pixels=doTakeScreenshot(this)
            pixels=this.Browser.getScreenshot();
        end

        function windowSize=doGetWindowSize(this)
            windowSize=this.Browser.Position(end-1:end);
        end

        function setWindowSize(this,width,height)
            this.setWebWindowSizeAndCenter(this.Browser,width,height);
        end

        function setWindowTitle(this,title)
            this.Browser.Title=title;
        end
    end

    methods
        function bringToFront(this)
            this.Browser.bringToFront();
        end

        function minimize(this)
            this.Browser.minimize();
        end

        function restore(this)
            this.Browser.restore();
        end

        function openDebugger(this)
            this.jsEval('cefclient.sendMessage("openDevTools")');
        end
    end

    methods(Access=private)
        function closeAndExit(this)
            this.close();
            exit;
        end
        function close(this)
            if isempty(this.CustomCloseCallback)
                try
                    this.dispose();
                catch
                end
            else
                this.CustomCloseCallback();
            end
        end
    end

    methods(Static,Access=private)
        function setWebWindowSizeAndCenter(webWindow,varargin)
            if codergui.internal.isMatlabOnline()


                availableSize=codergui.internal.WebWindowWebClient.getScreenSize();
            else

                availableSize=[...
                str2double(webWindow.executeJS('window.screen.availWidth')),...
                str2double(webWindow.executeJS('window.screen.availHeight'))];
            end
            if nargin>1
                if nargin==2
                    size=varargin{1};
                else
                    size=cell2mat(varargin(1:2));
                end
            else
                size=floor(availableSize*0.7);
            end
            screen=codergui.internal.WebWindowWebClient.sizeToPosition(size(1),size(2),availableSize);
            webWindow.setMinSize(ceil(size/2.5));
            webWindow.Position=screen;
        end

        function winPos=sizeToPosition(width,height,availableSize)
            if nargin<3
                availableSize=codergui.internal.WebWindowWebClient.getScreenSize();
            end
            if isscalar(width)
                size=[width,height];
            elseif isempty(width)
                size=availableSize;
            else
                size=width(1:2);
            end
            size=min(size,availableSize);


            titleBarHeightEstimate=floor(0.08*availableSize(2));
            size(2)=size(2)-titleBarHeightEstimate;



            screen=codergui.internal.WebWindowWebClient.getScreenSize();
            winPos=floor([(screen-size)/2,size]);
        end

        function screen=getScreenSize()
            screen=get(0,'screensize');
            screen=screen(3:4);
        end
    end
end

classdef DiagramWindow<handle




    properties(Constant,Hidden=true)
        DEBUG_PAGE_INDEX_URL='/toolbox/slrequirements/slrequirements/+slreq/+internal/+tracediagram/web/index-debug.html';
        PAGE_INDEX_URL='/toolbox/slrequirements/slrequirements/+slreq/+internal/+tracediagram/web/index.html';
        CLIENT_IDENTIFIER='SLREQTRACEDIAGRAM';
        PRODUCT_NAME='slreqtracediagram';

        CHANNEL_PREFIX=sprintf('/%s/%s/%s/',slreq.internal.tracediagram.utils.DiagramWindow.PRODUCT_NAME,slreq.internal.tracediagram.utils.DiagramWindow.CLIENT_IDENTIFIER);
        SYNC_CHANNEL_PREFIX='/slreqtracediagram/channel/';
        ICON_PATH=fullfile(matlabroot,'toolbox','shared','slreq','+slreq','+internal','+gui','slreqEditorPlugin','resources','icons','rtmx_24.png')
    end

    properties(Access=public)

        DebugUrl='';
        Url='';
        DebugWindow;
        Window;
        Subscription;

        DebugMode=true;
        PageTitle;
        CurrentWindow;
        InitialPageLoaded=false;
        PageLoadedCallBack;



TargetDiagramId
        WindowTitle;
        LastSavedPosition;
    end

    methods


        function this=DiagramWindow(diagramId,titleStr)


            this.PageLoadedCallBack=[];
            this.TargetDiagramId=diagramId;
            this.WindowTitle=titleStr;
        end


        function delete(this)
            if~isempty(this.Window)&&isvalid(this.Window)
                this.Window.delete();
            end


            this.Window=[];

            if~isempty(this.DebugWindow)&&isvalid(this.DebugWindow)
                this.DebugWindow.delete();
            end


            this.DebugWindow=[];

            if~isempty(this.Subscription)
                message.unsubscribe(this.Subscription)
                this.Subscription=[];
            end
        end

        function subscribe(this)%#ok<MANU>

        end

        function publish(this,type,msg)
            message.publish([this.CHANNEL_PREFIX,type],msg);
        end


        function handleDiagramMessage(this,msg)
            switch msg
            case 'initialPageLoaded'

                this.InitialPageLoaded=true;
                if isa(this.PageLoadedCallBack,'function_handle')
                    this.PageLoadedCallBack();
                    this.PageLoadedCallBack=[];
                end
            end
        end


        function createWindow(this)
            this.InitialPageLoaded=false;
            if~isempty(this.CurrentWindow)&&isvalid(this.CurrentWindow)
                this.CurrentWindow.delete();
            end

            if isempty(this.LastSavedPosition)
                position=getDefaultPosition();
            else
                position=this.LastSavedPosition;
            end

            connector.ensureServiceOn;
            connector.newNonce;
            if this.DebugMode
                this.Url=sprintf('%s',connector.getUrl([slreq.internal.tracediagram.utils.DiagramWindow.DEBUG_PAGE_INDEX_URL,'?viewid=',this.TargetDiagramId]));
            else
                this.Url=sprintf('%s%s%s',connector.getUrl(slreq.internal.tracediagram.utils.DiagramWindow.PAGE_INDEX_URL),'&viewid=',this.TargetDiagramId);
            end

            this.CurrentWindow=matlab.internal.webwindow(this.Url,'Position',position);

            this.CurrentWindow.Title=this.PageTitle;


            if this.DebugMode
                this.DebugWindow=this.CurrentWindow;
            else
                this.Window=this.CurrentWindow;
            end
        end

        function closingCallback(this,src,event)
            this.PageLoadedCallBack=[];
            this.LastSavedPosition=src.Position;
            src.close;

            this.InitialPageLoaded=false;
        end

        function refreshDiagramWindow(this)
            if this.DebugMode
                this.PageTitle=[this.WindowTitle,'- Debug'];
                this.CurrentWindow=this.DebugWindow;
            else
                this.PageTitle=this.WindowTitle;
                this.CurrentWindow=this.Window;
            end
        end


        function out=getOrCreateDiagramWindow(this)
            this.refreshDiagramWindow();
            if isempty(this.CurrentWindow)||~isvalid(this.CurrentWindow)||~this.CurrentWindow.isWindowValid
                this.createWindow();
            end
            this.CurrentWindow.CustomWindowClosingCallback=@(src,event)this.closingCallback(src,event);

            out=this.CurrentWindow;
        end
    end

    methods(Static)
        function windowObj=show(viewId,titleStr)
            if evalin('base','exist(''slreqtracediagramDebug'',''var'') == 1')&&evalin('base','slreqtracediagramDebug')
                debugMode=true;
            else
                debugMode=false;
            end

            windowObj=slreq.internal.tracediagram.utils.DiagramWindow(viewId,titleStr);
            windowObj.DebugMode=debugMode;

            out=windowObj.getOrCreateDiagramWindow();

            if out.isVisible
                out.bringToFront();
            end

            if windowObj.DebugMode
                out.executeJS('cefclient.sendMessage("openDevTools");');
            end
        end

        function out=getCurrentConfig()
            windowObj=slreq.internal.tracediagram.utils.DiagramWindow.getInstance();
            windowObj.refreshDiagramWindow();
            if isempty(windowObj.CurrentWindow)||~isvalid(windowObj.CurrentWindow)||~windowObj.CurrentWindow.isWindowValid
                out=[];
                return;
            end
            try
                outString=windowObj.CurrentWindow.executeJS('require(["slreqtracediagram/js/controllers/UIUtils"], function (uiUtils) {config = uiUtils.exportConfigToString();}); config');
                out=jsondecode(outString);
            catch
                out=[];
            end
        end
    end

    methods(Static,Hidden=true)

        function out=getInstance(doInit,doClear)
            persistent diagramWindow

            if nargin<1
                doInit=true;
            end

            if nargin<2
                doClear=false;
            end


            if isempty(diagramWindow)&&doInit
                diagramWindow=slreq.internal.tracediagram.utils.DiagramWindow();
            end

            if doClear
                clear diagramWindow;
                out=[];
            else
                out=diagramWindow;
            end


        end


        function out=getWindowList()
            out={};
            diagramWindow=slreq.internal.tracediagram.utils.DiagramWindow.getInstance(false);
            if~isempty(diagramWindow)
                if~isempty(diagramWindow.Window)&&isvalid(diagramWindow.Window)
                    out{end+1}=diagramWindow.Window;
                end

                if~isempty(diagramWindow.DebugWindow)&&isvalid(diagramWindow.DebugWindow)
                    out{end+1}=diagramWindow.DebugWindow;
                end
            end
        end


        function closeWindows()
            diagramWindow=slreq.internal.tracediagram.utils.DiagramWindow.getInstance(false);
            if~isempty(diagramWindow)
                diagramWindow.delete();
            end

            slreq.internal.tracediagram.utils.DiagramWindow.getInstance(false,true);
        end
    end
end

function out=getDefaultPosition()
    screenSize=get(groot,'ScreenSize');
    screenSize=screenSize(3:4);
    preferredWinSize=[600,400];

    winPos=max([0,0],(screenSize-preferredWinSize)/2)/2;
    out=[winPos(1),winPos(2),winPos(1)+800,winPos(2)+600];
end

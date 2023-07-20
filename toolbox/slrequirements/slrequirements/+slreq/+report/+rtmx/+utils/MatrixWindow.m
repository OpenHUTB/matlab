classdef MatrixWindow<handle
    properties(Constant,Hidden=true)
        DEBUG_PAGE_INDEX_URL='toolbox/slrequirements/slrequirements/+slreq/+report/+rtmx/web/index-debug.html';
        PAGE_TITLE=getString(message('Slvnv:slreq_rtmx:WindowTitle'));
        PAGE_INDEX_URL='toolbox/slrequirements/slrequirements/+slreq/+report/+rtmx/web/index.html';
        DEBUG_TITLE=[getString(message('Slvnv:slreq_rtmx:WindowTitle')),'Debug'];
        CLIENT_IDENTIFIER='SLREQRTMX';
        PRODUCT_NAME='slreqrtmx';

        DEBUG_BASE_URL=sprintf('%s%s%s',slreq.report.rtmx.utils.MatrixWindow.DEBUG_PAGE_INDEX_URL,'?clientid=',slreq.report.rtmx.utils.MatrixWindow.CLIENT_IDENTIFIER);
        BASE_URL=sprintf('%s%s%s',slreq.report.rtmx.utils.MatrixWindow.PAGE_INDEX_URL,'?clientid=',slreq.report.rtmx.utils.MatrixWindow.CLIENT_IDENTIFIER);
        CHANNEL_PREFIX=sprintf('/%s/%s/%s/',slreq.report.rtmx.utils.MatrixWindow.PRODUCT_NAME,slreq.report.rtmx.utils.MatrixWindow.CLIENT_IDENTIFIER);
        SYNC_CHANNEL_PREFIX='/slreqrtmx/channel/';
        ICON_PATH=fullfile(matlabroot,'toolbox','shared','slreq','+slreq','+internal','+gui','slreqEditorPlugin','resources','icons','rtmx_24.png')
    end

    properties(Access=public)
        DebugUrl='';
        Url='';
        DebugWindow;
        Window;
        Subscription;

        MF0Model;
        MF0ModelUUID;
        MF0Channel;
        ConnectorChannel;
        MF0Sync;
        DebugMode=true;
        PageTitle;
        CurrentWindow;
        InitialPageLoaded=false;
        PageLoadedCallBack;
    end

    methods


        function this=MatrixWindow()









            this.subscribe();
            this.PageLoadedCallBack=[];
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

        function subscribe(this)
            this.Subscription=message.subscribe([this.CHANNEL_PREFIX,'status'],@(msg)this.handleMatrixMessage(msg));
        end

        function publish(this,type,msg)
            message.publish([this.CHANNEL_PREFIX,type],msg);
        end



        function handleMatrixMessage(this,msg)
            switch msg
            case 'terminatebyuser'
                dataExporter=slreq.report.rtmx.utils.RTMXReqDataExporter.getInstance();
                dataExporter.terminateByUser()
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
            this.CurrentWindow=matlab.internal.webwindow(this.Url);
            this.CurrentWindow.Title=this.PageTitle;

            if this.DebugMode
                this.DebugWindow=this.CurrentWindow;
            else
                this.Window=this.CurrentWindow;
            end
        end
        function closingCallback(this,src,event)

            this.PageLoadedCallBack=[];
            src.close();
            this.InitialPageLoaded=false;
        end

        function refreshMatrixWindow(this)
            if this.DebugMode
                this.Url=sprintf('%s%s%s',connector.getUrl(slreq.report.rtmx.utils.MatrixWindow.DEBUG_PAGE_INDEX_URL),'&uuid=',this.MF0ModelUUID);
                this.PageTitle=this.DEBUG_TITLE;
                this.CurrentWindow=this.DebugWindow;
            else
                this.Url=sprintf('%s%s%s',connector.getUrl(slreq.report.rtmx.utils.MatrixWindow.PAGE_INDEX_URL),'&uuid=',this.MF0ModelUUID);
                this.PageTitle=this.PAGE_TITLE;
                this.CurrentWindow=this.Window;
            end

            window=this.CurrentWindow;
        end



        function out=getOrCreateMatrixWindow(this)
            this.refreshMatrixWindow();
            if isempty(this.CurrentWindow)||~isvalid(this.CurrentWindow)||~this.CurrentWindow.isWindowValid
                this.createWindow();
            end

            this.CurrentWindow.CustomWindowClosingCallback=@(src,event)this.closingCallback(src,event);

            out=this.CurrentWindow;
        end


    end

    methods(Static)
        function out=showMatrixWindow(topArtifactInfo,leftArtifactInfo,options)
            if evalin('base','exist(''slreqrtmxDebug'',''var'') == 1')&&evalin('base','slreqrtmxDebug')
                debugMode=true;
            else
                debugMode=false;
            end
            windowObj=slreq.report.rtmx.utils.MatrixWindow.getInstance();
            windowObj.DebugMode=debugMode;

            out=windowObj.getOrCreateMatrixWindow();

            out.show();
            out.bringToFront();

            if windowObj.DebugMode
                out.executeJS('cefclient.sendMessage("openDevTools");');
            end

            if nargin>0
                channelMessage.topArtifacts=topArtifactInfo;
                channelMessage.leftArtifacts=leftArtifactInfo;
                channelMessage.options=options;
                channelStr=jsonencode(channelMessage);
                if windowObj.InitialPageLoaded
                    windowObj.publish('ADDNEW',channelStr);
                else
                    windowObj.PageLoadedCallBack=@(~,~)windowObj.publish('ADDNEW',channelStr);
                end

            end
        end

        function out=getCurrentConfig()
            windowObj=slreq.report.rtmx.utils.MatrixWindow.getInstance();
            windowObj.refreshMatrixWindow();
            if isempty(windowObj.CurrentWindow)||~isvalid(windowObj.CurrentWindow)||~windowObj.CurrentWindow.isWindowValid
                out=[];
                return;
            end
            try
                outString=windowObj.CurrentWindow.executeJS('require(["slreqrtmx/js/controllers/UIUtils"], function (uiUtils) {config = uiUtils.exportConfigToString();}); config');
                out=jsondecode(outString);
            catch
                out=[];
            end
        end
    end

    methods(Static,Hidden=true)

        function out=getInstance(doInit,doClear)
            persistent matrixWindow

            if nargin<1
                doInit=true;
            end

            if nargin<2
                doClear=false;
            end


            if isempty(matrixWindow)&&doInit
                matrixWindow=slreq.report.rtmx.utils.MatrixWindow();
            end


            if doClear
                clear matrixWindow;
                out=[];
            else
                out=matrixWindow;
            end


        end


        function publishAddNew(msg)
            mtWindow=slreq.report.rtmx.utils.MatrixWindow.getInstance();
            mtWindow.publish('ADDNEW',msg)
        end


        function publishUpdateProgress(progress)
            mtWindow=slreq.report.rtmx.utils.MatrixWindow.getInstance();
            mtWindow.publish('updateProgress',jsonencode(progress));
        end


        function publishAddFilter(filterObj)
            mtWindow=slreq.report.rtmx.utils.MatrixWindow.getInstance();
            mtWindow.publish('addFilter',jsonencode(filterObj));
        end


        function publishClearFilter(filterObj)
            mtWindow=slreq.report.rtmx.utils.MatrixWindow.getInstance();
            mtWindow.publish('clearFilter',jsonencode(filterObj));
        end


        function queryCurrentConfig()
            mtWindow=slreq.report.rtmx.utils.MatrixWindow.getInstance();
            mtWindow.publish('QUERYCONFIG','')
        end

        function out=getWindowList()
            out={};
            matrixWindow=slreq.report.rtmx.utils.MatrixWindow.getInstance(false);
            if~isempty(matrixWindow)
                if~isempty(matrixWindow.Window)&&isvalid(matrixWindow.Window)
                    out{end+1}=matrixWindow.Window;
                end

                if~isempty(matrixWindow.DebugWindow)&&isvalid(matrixWindow.DebugWindow)
                    out{end+1}=matrixWindow.DebugWindow;
                end
            end
        end


        function closeWindows()
            matrixWindow=slreq.report.rtmx.utils.MatrixWindow.getInstance(false);
            if~isempty(matrixWindow)
                matrixWindow.delete();








            end

            slreq.report.rtmx.utils.MatrixWindow.getInstance(false,true);
        end
    end
end
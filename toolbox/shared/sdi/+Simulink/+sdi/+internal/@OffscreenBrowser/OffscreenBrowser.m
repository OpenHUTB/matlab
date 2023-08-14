


classdef OffscreenBrowser<handle


    methods


        function obj=OffscreenBrowser(varargin)
            Simulink.sdi.internal.startConnector;
            obj.openGUI();
        end


        function delete(this)
            close(this);
        end


        function close(this,varargin)
            if~isempty(this.Dialog)
                delete(this.Dialog);
                this.Dialog=[];
            end
        end


        function hide(this)

            if~isempty(this.Dialog)
                this.Dialog.hide();
            end
        end


        function show(this)

            if~isempty(this.Dialog)
                this.Dialog.show();
            end
        end


        function setSize(this,w,h)
            if~isempty(this.Dialog)
                pos=this.Dialog.CEFWindow.Position;
                pos(3)=w+Simulink.sdi.internal.OffscreenBrowser.EXTRA_SDI_WIDTH;
                pos(4)=h+Simulink.sdi.internal.OffscreenBrowser.EXTRA_SDI_HEIGHT;
                this.Dialog.CEFWindow.Position=pos;
                this.Size=[w,h];
            end
        end


        function ret=getClient(~,bComparison)
            ret=[];
            if nargin>1&&bComparison
                appName=Simulink.sdi.internal.OffscreenBrowser.COMPARISON_CLIENT;
            elseif Simulink.sdi.internal.WebGUI.debugMode()
                appName=Simulink.sdi.internal.OffscreenBrowser.DEBUG_CLIENT;
            else
                appName=Simulink.sdi.internal.OffscreenBrowser.REL_CLIENT;
            end
            clients=Simulink.sdi.WebClient.getAllClients(appName);
            for idx=1:length(clients)
                if strcmpi(clients(idx).Status,'connected')
                    ret=clients(idx);
                    return
                end
            end
        end
    end


    methods(Hidden,Static)


        function bRet=isRunning()
            if Simulink.sdi.internal.WebGUI.debugMode()
                appName=Simulink.sdi.internal.OffscreenBrowser.DEBUG_CLIENT;
            else
                appName=Simulink.sdi.internal.OffscreenBrowser.REL_CLIENT;
            end
            bRet=Simulink.sdi.WebClient.appIsConnected(appName);
        end

    end


    methods(Access=private)


        function openGUI(this)

            url=[Simulink.sdi.internal.WebGUI.getURL(),Simulink.sdi.internal.OffscreenBrowser.URL_PARAM];


            if Simulink.sdi.getUseSystemBrowser
                web(url,'-browser');
            else
                title='Hidden SDI Snapshot';
                bUseCEF=true;
                bHide=true;
                context={};
                bIsOffscreen=true;
                bDebugMode=Simulink.sdi.internal.WebGUI.debugMode();
                defaultPosition=Simulink.sdi.internal.WebGUI.getSetGeometry();
                this.Dialog=Simulink.HMI.BrowserDlg(...
                url,title,defaultPosition,...
                [],...
                bUseCEF,...
                bDebugMode,...
                @()onBrowserClose(this),...
                bHide,...
                context,...
                bIsOffscreen);
            end
        end

    end


    methods(Hidden)


        function onBrowserClose(~)
            Simulink.sdi.Instance.getSetOffscreenBrowser([]);
        end

    end


    properties(Hidden)
Dialog
Size
    end


    properties(Hidden,Constant)
        URL_PARAM='&offscreen=true';
        REL_CLIENT='sdi_offscreen'
        COMPARISON_CLIENT='SDIComparison_offscreen'
        DEBUG_CLIENT='sdi-debug_offscreen'
        EXTRA_SDI_WIDTH=332
        EXTRA_SDI_HEIGHT=0
    end

end

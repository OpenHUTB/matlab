
classdef MACEUI<Advisor.WindowBase




    properties(Hidden)
        REL_URL='toolbox/simulink/slcheck_ma_config_editor/ma_config_editor/index.html?';
        DEBUG_URL='toolbox/simulink/slcheck_ma_config_editor/ma_config_editor/index-debug.html?';
        READY_TO_SHOW_CHANNEL='ReadyToShow';
        appID=[];
    end

    properties(Access=private)
        ReadyToShowSubscription;
        OpenInBrowser='';
        IExplorer;
        StartOnEdittimeView=false;
    end


    properties(Access=public)
        model='';
        type='';
        isMACELoaded='';

        ID='';
        App='MACE';
    end


    events(Hidden)



        ReadyToShow;
    end

    methods
        function createSession(this)
            appID='1234567890';
            this.appID=appID;
            Advisor.UIService.getInstance().register(this);
            this.IsOpen=true;
            this.WindowTitle=DAStudio.message('ModelAdvisor:engine:MACETitle');
        end

        function destroySession(this)
            this.isInitiated=false;
            this.IsOpen=false;
            this.Window=[];
            this.URL='';
            this.isMACELoaded='';
            Advisor.UIService.getInstance().unregister(this.App,this.ID);
        end

        function sizeData=defineWindowSize(this)

            sizeData=struct();

            width=1200;
            height=800;

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

            sizeData.size=[xOffset,yOffset,width,height];
            sizeData.minSize=[800,600];
        end

        function retStruct=defineURLQueryStruct(this)

            retStruct=struct();
            retStruct.appID='1234567890';
            mp=ModelAdvisor.Preferences;
            if~mp.ShowEdittimeviewInMACE
                StartOnEdittimeView='hidden';
            elseif this.StartOnEdittimeView
                StartOnEdittimeView='on';
            else
                StartOnEdittimeView='off';
            end
            retStruct.StartOnEdittimeView=StartOnEdittimeView;
        end
    end


    methods(Hidden)

        function startOnEdittimeView(this,value)
            this.StartOnEdittimeView=value;
        end

        function setIcon(this,iconPath)
            if isa(this.Window,'Simulink.HMI.BrowserDlg')&&isa(this.Window.CEFWindow,'matlab.internal.webwindow')
                this.Window.CEFWindow.Icon=iconPath;
            end
        end
    end


    methods(Hidden,Static)

        function singleObj=getInstance()
            persistent MACEManager;
            if isempty(MACEManager)||~isvalid(MACEManager)
                MACEManager=ModelAdvisorWebUI.interface.MACEUI;
            end
            singleObj=MACEManager;
        end
    end
end
classdef AdvisorWindow<Advisor.WindowBase

    properties(Access=public)
        ID='';
        App='ModelAdvisor';

        model='';
        system='';
        config='';

        Controller=[];
    end


    properties(Hidden)
        REL_URL='toolbox/simulink/advisor/advisor_ui/web/index.html';
        DEBUG_URL='toolbox/simulink/advisor/advisor_ui/web/index-debug.html';
    end

    methods(Hidden)
        function initTestInstance(this)
            this.initUrl();
            this.createSession([]);
        end
    end

    methods
        function this=AdvisorWindow(modelName)
            this.model=modelName;
        end

        function setSystem(this,system)
            this.system=system;
        end

        function setConfiguration(this,config)
            this.config=config;
        end

        function win=getWindow(this)
            win=this.Window;
        end

        function publishToUI(this,event,eventdata)
            Advisor.UIService.getInstance().publishToUI(this.App,this.ID,event,eventdata);
        end
    end


    methods(Access=public)

        function createSession(this,varargin)

            if nargin>1
                maObj=varargin{1};
            else
                maObj=[];
            end

            this.Controller=Advisor.UIController(this.model,this.ID);

            if~isempty(maObj)
                this.Controller.setMaObj(maObj);
                this.system=maObj.System;
            elseif~isempty(this.system)
                this.Controller.setConfiguration(this.config);
                this.Controller.setSystem(this.system);
            end
            Advisor.UIService.getInstance().register(this);

            if this.bShowGUI

                title=DAStudio.message('Advisor:ui:advisor_rootpane_title');
                if~isempty(this.system)
                    title=[title,' - ',this.system];
                else
                    title=[title,' - ',this.model];
                end
                if~isempty(this.config)
                    title=[title,' - ',this.config];
                end

                this.setWindowTitle(title);
            end
        end

        function destroySession(this,varargin)
            if isa(this.Controller,'Advisor.UIController')
                this.Controller.delete();
            end
            Advisor.UIService.getInstance().unregister(this.App,this.ID);

        end

        function retStruct=defineURLQueryStruct(this)
            retStruct=struct();
            retStruct.modelname=this.model;
            retStruct.system=this.system;
            retStruct.configuration=this.config;
        end

        function sizeData=defineWindowSize(this)
            sizeData=struct();

            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);

            width=0.8*screenWidth;
            height=0.8*screenHeight;
            xOffset=(screenWidth-width)/2;
            yOffset=(screenHeight-height)/2;

            sizeData.size=[xOffset,yOffset,width,height];

            minWidth=0.6*screenWidth;
            minHeight=0.6*screenHeight;
            sizeData.minSize=[minWidth,minHeight];
        end
    end

end


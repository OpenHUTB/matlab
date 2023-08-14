classdef ExclusionEditorWindow<Advisor.WindowBase




    properties(Access=public)
        ID='';
        App='ClonesExclusionEditor';


        Controller;
        model;
    end

    properties(Access=private)
        width=700;
        height=650;

        modelCloseListener;
        modelNameChangeListener;
    end

    properties(Hidden)
        REL_URL='toolbox/clone_detection/clonedetection_exclusion_editor/web/clonedetection_exclusion_editor_js/index.html';
        DEBUG_URL='toolbox/clone_detection/clonedetection_exclusion_editor/web/clonedetection_exclusion_editor_js/index-debug.html';
    end

    methods(Access=public)
        function this=ExclusionEditorWindow(varargin)
            this=this@Advisor.WindowBase(varargin);


            if nargin==1
                this.model=varargin{1};
            end
            this.setWindowTitle(this.getWindowTitleMsg());

            this.modelCloseListener=Simulink.listener(get_param(this.model,'object'),'CloseEvent',@(src,eventData)this.onModelClose(src));

            this.modelNameChangeListener=Simulink.listener(get_param(this.model,'object'),'PostSaveEvent',@(src,eventData)this.onModelNameChange(src));
        end

        function publishToUI(this,event,eventdata)
            Advisor.UIService.getInstance().publishToUI(this.App,this.ID,event,eventdata);
        end

        function createSession(this,varargin)
            this.Controller=CloneDetector.ExclusionEditor(this.model,this.ID);
            Advisor.UIService.getInstance().register(this);
            this.isInitiated=true;
        end

        function destroySession(this,varargin)
            Advisor.UIService.getInstance().unregister(this.App,this.ID);
            CloneDetector.ExclusionEditorUIService.getInstance.remove(this.model);

            filterServiceClones=slcheck.CloneDetectionFilterService.getInstance;
            filterServiceClones.remove(this.model);
        end

        function retStruct=defineURLQueryStruct(~)
            retStruct=struct();
        end

        function sizeData=defineWindowSize(this)
            sizeData=struct();
            w=this.width;
            h=this.height;
            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=0.8*screenWidth;
            maxHeight=0.8*screenHeight;
            if maxWidth>0&&this.width>maxWidth
                w=maxWidth;
            end
            if maxHeight>0&&this.height>maxHeight
                h=maxHeight;
            end

            xOffset=(screenWidth-this.width)/2;
            yOffset=(screenHeight-this.height)/2;

            sizeData.size=[xOffset,yOffset,w,h];
            sizeData.minSize=[600,400];
        end

        function delete(this)
            delete@Advisor.WindowBase(this);
        end
    end

    methods(Hidden)
        function onModelClose(this,src)
            if~isa(src,'Simulink.BlockDiagram')
                return;
            end

            if~strcmpi(this.model,src.Name)



                return;
            end

            this.Controller.closeChildWindows();
            this.close();
            CloneDetector.ExclusionEditorUIService.getInstance.remove(this.model);
        end

        function onModelNameChange(this,src)
            if~isa(src,'Simulink.BlockDiagram')
                return;
            end

            if~strcmpi(this.model,src.Name)
                this.Controller.closeChildWindows();
                this.close();
                CloneDetector.ExclusionEditorUIService.getInstance.remove(this.model);
            end
        end

        function title=getWindowTitleMsg(this)
            saveDataLoc=this.model;
            if~isempty(this.Controller)&&~isempty(this.Controller.getExternalFilePath())
                saveDataLoc=this.Controller.getExternalFilePath();
            end
            title=['Clone Detection Exclusion Editor - ',saveDataLoc];
        end

    end


end

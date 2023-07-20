classdef ExclusionEditorWindow<Advisor.WindowBase




    properties(Access=public)
        ID='';
        App='ExclusionEditor';

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
        REL_URL='toolbox/simulink/slcheck_exclusioneditor/ma_exclusion_editor/index.html';
        DEBUG_URL='toolbox/simulink/slcheck_exclusioneditor/ma_exclusion_editor/index-debug.html';
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

        function delete(this)
            delete@Advisor.WindowBase(this);
        end
    end

    methods(Access=public)

        function createSession(this,varargin)
            this.Controller=Advisor.ExclusionEditor(this.model,this.ID);
            Advisor.UIService.getInstance().register(this);
            this.isInitiated=true;
        end

        function destroySession(this,varargin)
            this.Controller.closeChildWindows();
            Advisor.UIService.getInstance().unregister(this.App,this.ID);
            Advisor.ExclusionEditorUIService.getInstance.remove(this.model);
        end

        function retStruct=defineURLQueryStruct(this)
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

        function publishToUI(this,event,eventdata)
            Advisor.UIService.getInstance().publishToUI(this.App,this.ID,event,eventdata);
        end
    end

    methods(Hidden)
        function[checkIDs,checkOptions,checksToBeRemoved]=getOptionsForRMBSchema(this,prop,ssid)


            checksToBeRemoved={};
            checkArray={};
            checkIDs={};
            checkOptions={};
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if~isempty(mdladvObj)&&strcmp(bdroot(mdladvObj.SystemName),this.model)...
                &&~isempty(mdladvObj.ResultMap)
                if mdladvObj.ResultMap.isKey(ssid)
                    checkArray=mdladvObj.ResultMap(ssid);
                end
                checkIDs=checkArray(1:2:end);
                checkOptions=checkArray(2:2:end);
                [checkOptions,idx]=sort(checkOptions);
                checkIDs=checkIDs(idx);
            end
            checkIDs=[{'.*',DAStudio.message('slcheck:filtercatalog:CheckSelectorGUI')},checkIDs];
            checkOptions=[DAStudio.message('ModelAdvisor:engine:ExclusionAllChecks'),...
            DAStudio.message('ModelAdvisor:engine:CheckSelector'),...
            checkOptions];

            manager=slcheck.getAdvisorFilterManager(this.model);

            spec=manager.getFilterSpecification(slcheck.getFilterTypeEnum(prop.Type),...
            slcheck.getsid(prop.value));


            if isempty(spec)
                return;
            end

            for idx=1:spec.checks.Size
                if strcmp(spec.checks.at(idx),'.*')
                    checkIDs=[];
                    return;
                end
                checksToBeRemoved{end+1}=spec.checks.at(idx);%#ok<AGROW>
            end

            [checkIDs,i]=setdiff(checkIDs,checksToBeRemoved);
            checkOptions=checkOptions(i);

        end


        function onModelClose(this,src)
            if~isa(src,'Simulink.BlockDiagram')
                return;
            end

            if~strcmpi(this.model,src.Name)



                return;
            end

            this.Controller.closeChildWindows();
            this.close();
            Advisor.ExclusionEditorUIService.getInstance.remove(this.model);
        end

        function onModelNameChange(this,src)
            if~isa(src,'Simulink.BlockDiagram')
                return;
            end

            if~strcmpi(this.model,src.Name)
                this.Controller.closeChildWindows();
                this.close();
                Advisor.ExclusionEditorUIService.getInstance.remove(this.model);
            end
        end

        function title=getWindowTitleMsg(this)
            saveDataLoc=get_param(this.model,'MAModelFilterFile');
            if isempty(saveDataLoc)
                title=[DAStudio.message('ModelAdvisor:engine:ModelAdvisorExclusionEditor'),' - ',this.model];
            else
                title=[DAStudio.message('ModelAdvisor:engine:ModelAdvisorExclusionEditor'),' - ',saveDataLoc];
            end
        end

    end


end



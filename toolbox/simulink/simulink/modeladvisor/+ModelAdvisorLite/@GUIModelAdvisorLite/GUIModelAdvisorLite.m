classdef GUIModelAdvisorLite<handle





    properties(Access='private')
        mdl;
        dlg;


        IsRunning;
        IsResultAvailable;
        eventListener=[];
        highlight=false;

        NumPass;
        NumFail;
        NumWarn;
        NumNotRun;
        status='';

        position=[300,300];
    end

    methods

        function this=GUIModelAdvisorLite(mdl)
            if ishandle(mdl)
                this.mdl=Simulink.ID.getFullName(mdl);
            elseif isempty(Simulink.ID.checkSyntax(mdl))
                this.mdl=Simulink.ID.getFullName(mdl);
            else
                this.mdl=mdl;
            end

            loc=get_param(this.mdl,'Location');
            this.setPosition([loc(1)+100,loc(2)+100]);
            this.initResults();
            this.updateStats();
            this.updateIsRunning();
            this.setEventHandler();
        end

        function setPosition(this,newPosition)
            this.position=newPosition;
        end

        function updateIsRunning(this)
            if ModelAdvisor.isRunning
                this.IsRunning=true;
            end
        end

        function configFile=getConfigFile(this)
            configFile='';

            maObj=this.getMAObj();
            if~isempty(maObj)
                configFile=maObj.configFilePath;
            else
                PrefFile=fullfile(prefdir,'mdladvprefs.mat');
                if exist(PrefFile,'file')
                    mdladvprefs=load(PrefFile);
                    if isfield(mdladvprefs,'ConfigPrefs')&&isfield(mdladvprefs.ConfigPrefs,'FilePath')
                        configFile=mdladvprefs.ConfigPrefs.FilePath;
                    end
                end
            end
        end

        function position=getPosition(this)
            position=this.position;
        end

        function show(this)
            maObj=this.getMAObj();
            if~isempty(maObj)&&~(isempty(maObj.MAExplorer))&&...
                maObj.MAExplorer.isVisible
                maObj.viewMode='MADashboard';
                this.setPosition(maObj.MAExplorer.position);
                maObj.MAExplorer.hide;
            end

            dialog=DAStudio.ToolRoot.getOpenDialogs.find...
            ('dialogTag',ModelAdvisorLite.GUIModelAdvisorLite.getDialogTag(this.mdl));

            if isempty(dialog)
                this.dlg=DAStudio.Dialog(this);
            else
                this.dlg=dialog;
                dialog.show;
            end
        end
        function eventBroadcast(this,event)
            if strcmpi(event,'MESleep')
                this.IsRunning=true;
            elseif strcmpi(event,'MEWake')
                this.IsRunning=false;
                this.updateStats();
            end
            this.dlg.restoreFromSchema();
        end

        function status=getStatusText(this)
            status=this.status;
        end

        function setStatusText(this,in)
            this.status=in;
        end

        function runTaskAdvisor(this)
            this.IsRunning=true;
            this.setStatusText('');
            this.dlg.refresh;
            try
                mdladvObj=this.getMAObj();
                if isempty(mdladvObj)






                    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(this.mdl,'new','_modeladvisor_');
                    mdladvObj.displayExplorer;
                end
                ModelAdvisorLite.GUIModelAdvisorLite.runSelectedNode(this.mdl);
            catch E
                errordlg(E.message);
                this.IsRunning=false;
                return;
            end
            if this.getMAObj.runInBackground&&ModelAdvisor.isRunning
                return;
            end
            this.IsRunning=false;
            this.IsResultAvailable=true;
            this.updateStats();
            this.dlg.restoreFromSchema();
        end

        function showReport(this,arg)
            mdladvObj=this.getMAObj();
            if~isempty(mdladvObj)
                rptName=mdladvObj.generateReport(mdladvObj.taskAdvisorRoot);
                if~isempty(arg)
                    web([rptName,'?',arg]);
                else
                    web(rptName);
                end
            end
        end

        function out=getHighlight(this)
            out=this.highlight;
        end

        function setHighlight(this)
            this.highlight=~this.highlight;
        end

        function clickHighlight(this)
            mdladvObj=this.getMAObj();
            if isempty(mdladvObj)
                return;
            end
            Simulink.ModelAdvisor.getActiveModelAdvisorObj(mdladvObj);
            this.setHighlight();
            setpref('modeladvisor','ShowInformer',this.getHighlight());
            memenus=mdladvObj.MEmenus;
            if strcmp(memenus.ShowInformerGUI.on,'on')
                memenus.ShowInformerGUI.on='off';
            else
                memenus.ShowInformerGUI.on='on';
            end

            this.dlg.refresh();
        end

        function cancelBackgroundRun(obj)
            ModelAdvisorLite.GUIModelAdvisorLite.runSelectedNode(obj.mdl);
        end

        function switchToFullMode(this)
            activemdladvObj=this.getMAObj;

            try
                if~isempty(activemdladvObj)&&...
                    isa(activemdladvObj,'Simulink.ModelAdvisor')&&...
                    ~(isempty(activemdladvObj.MAExplorer))&&...
                    strcmp(activemdladvObj.CustomTARootID,'_modeladvisor_')&&...
                    ~activemdladvObj.MAExplorer.isVisible
                    pos=activemdladvObj.MAExplorer.position;
                    activemdladvObj.MAExplorer.position=[this.dlg.position(1),this.dlg.position(2),pos(3),pos(4)];
                    activemdladvObj.viewMode='MAStandardUI';
                    activemdladvObj.MAExplorer.show;
                else
                    modeladvisor(this.mdl,'MAStandardUI');
                    activemdladvObj=this.getMAObj();
                    activemdladvObj.MAExplorer.show;
                end
                ModelAdvisorLite.GUIModelAdvisorLite.closeGUI(this.mdl);
            catch E
                disp(E.message);
            end
        end

        function initResults(this)
            mdladvObj=this.getMAObj;
            if~isempty(mdladvObj)
                this.highlight=mdladvObj.ShowInformer;
            else
                if ispref('modeladvisor','ShowInformer')
                    this.highlight=getpref('modeladvisor','ShowInformer');
                else
                    this.highlight=0;
                    setpref('modeladvisor','ShowInformer',0);
                end
            end
            this.IsResultAvailable=false;
            this.IsRunning=false;
            this.NumPass=0;
            this.NumFail=0;
            this.NumWarn=0;
            this.NumNotRun=0;
        end

        function setProgressMessage(this,text)
            this.ProgressMessage=['                ',...
            '                ',...
            text];
        end

    end

    methods(Access=private)

        function updateStats(this)

            maObj=this.getMAObj();
            if~isempty(maObj)
                counterStructure=modeladvisorprivate('modeladvisorutil2',...
                'getNodeSummaryInfo',maObj.taskAdvisorRoot);
                this.NumPass=counterStructure.passCt;
                this.NumFail=counterStructure.failCt;
                this.NumWarn=counterStructure.warnCt;
                this.NumNotRun=counterStructure.nrunCt;
                this.IsResultAvailable=true;
            end
        end

        function maObj=getMAObj(this)


            am=Advisor.Manager.getInstance;
            applicationObj=am.getApplication('advisor','_modeladvisor_',...
            'Root',this.mdl,'Legacy',true,'MultiMode',false,...
            'token','MWAdvi3orAPICa11');


            if isempty(applicationObj)
                maObj=[];
            else
                maObj=applicationObj.getRootMAObj();




                if isempty(maObj.SystemName)||~strcmp(maObj.SystemName,getfullname(this.mdl))||...
                    isempty(maObj.CheckCellArray)||~strcmp(maObj.TaskAdvisorRoot.ID,'SysRoot')
                    maObj=[];
                end
            end
        end
    end


    methods(Static=true)

        function dlg=findMALiteDialog(mdl)
            dlg=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag',...
            ModelAdvisorLite.GUIModelAdvisorLite.getDialogTag(mdl));
        end

        function runSelectedNode(mdl)
            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(mdl);
            if mdladvObj.isSleeping
                mdladvObj.setStatus(DAStudio.message('ModelAdvisor:engine:CancelBackgroundRun'));
                parallelRun=ModelAdvisor.ParallelRun.getInstance();
                parallelRun.cancelRun();
                return;
            end
            if~isempty(mdladvObj)&&isa(mdladvObj.MAExplorer,'DAStudio.Explorer')
                imme=DAStudio.imExplorer(mdladvObj.MAExplorer);
                currentNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
                currentNode.run;
            end
        end

        function openReport(mdl)
            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(mdl);
            if~isempty(mdladvObj)&&isa(mdladvObj.MAExplorer,'DAStudio.Explorer')
                imme=DAStudio.imExplorer(mdladvObj.MAExplorer);
                currentNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
                rptName=mdladvObj.generateReport(currentNode);
                web(rptName);
            end
        end

        function tag=getDialogTag(mdl)

            mdl=getfullname(mdl);
            tag=['malite_',mdl];
        end

        function switchToLiteMode(sysName)
            obj=ModelAdvisorLite.GUIModelAdvisorLite(sysName);
            obj.show();
        end


        function closeGUI(mdl)
            dialog=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag',...
            ModelAdvisorLite.GUIModelAdvisorLite.getDialogTag(mdl));
            if~isempty(dialog)
                dialog.delete;
            end
        end
    end

end



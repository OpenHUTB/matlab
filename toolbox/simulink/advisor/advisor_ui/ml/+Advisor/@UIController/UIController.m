classdef UIController<handle
    properties(Access=private)
        maObj=[];

        windowId=[];

        rootmodel='';
        system='';
        configuration='';

        prefCacheFile='ModelAdvisorPrefCache.mat';

        exportReportType='html';
        exportReportTemplate='';

        SaveJustificationToModel=true;
        JustificationFileName='';

        currentTreeSelection='';

    end

    methods
        function obj=UIController(model,windowId)
            obj.rootmodel=model;
            obj.windowId=windowId;
            if isJaLocale
                obj.exportReportTemplate=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','templates','default_ja.dotx');
            else
                obj.exportReportTemplate=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','templates','default.dotx');
            end
        end

        function delete(this)
            this.rootmodel='';
            this.system='';
        end
    end

    methods(Access=public)
        function setMaObj(this,maObj)
            this.maObj=maObj;
            this.system=maObj.System;
        end

        function setConfiguration(this,config)
            this.configuration=config;
        end
    end

    methods(Hidden)
        result=getModelHierarchy(this);
        result=setSystem(this,system);
        result=getCheckTree(this);

        result=openMACE(this);
        result=loadConfig(this,varargin);
        result=restoreDefaultConfig(this);
        result=associateConfigToModel(this);
        result=getRecentConfigs(this);
        setRecentConfigs(this,configFullFile);

        result=toggleCheckHighlight(this,state);
        result=toggleExclusionHighlight(this,state);

        result=getResultStatusSummary(this);

        result=getTaskInfo(this,taskId);
        result=getTaskStatus(this);
        result=getTaskResult(this);
        result=getDetails(this,taskId,RDObjId);
        result=getCheckDetails(this,taskId);

        result=setSelectionStatus(this,instanceID,newValue);
        result=getTreeNodeInfo(this,taskObj);

        result=runChecks(this,instanceId);
        result=cancelRun(this);
        result=fixChecks(this,instanceId);
        result=justify(this,instanceId,RDId,message);
        result=deleteJustification(this,taskId,RDId);

        result=setExportReportType(this,type);
        result=setExportReportTemplate(this);

        result=exportReport(this,reptype);

        result=openCSH(this,taskID);

        result=evalLink(this,link);
        result=highliteSID(this,taskId,RDId);

        result=sendIdToWorkspace(this,taskId,IdType);

        result=isActionEnabled(this,actionId);

        selectNode(this,nodeId);
        deselectNode(this,nodeId);
        focusNode(this,nodeId);



        function id=getCurrentTreeSelection(this)
            id=this.currentTreeSelection;
        end
    end
    methods(Access=private)
        function initMA(this)
            if~isempty(this.configuration)
                this.maObj=Simulink.ModelAdvisor.getModelAdvisor(this.system,'new','_modeladvisor_','configuration',this.configuration);
            else
                this.maObj=Simulink.ModelAdvisor.getModelAdvisor(this.system,'new','_modeladvisor_');
            end
            this.maObj.AdvisorWindow=Advisor.UIService.getInstance().getWindowById('ModelAdvisor',this.windowId);
            if this.maObj.ContinueViewExistRpt==true&&~isempty(this.maObj.AdvisorWindow)
                this.maObj.AdvisorWindow.close();
            end
        end

        function out=truncatePath(this,path)
            parts=strsplit(path,filesep);
            out=['...',filesep,strjoin(parts(end-2:end),filesep)];
        end

        report=updateReportForTask(this,TaskId);
    end

end

function bool=isJaLocale
    locale=feature('locale');
    lang=locale.messages;
    if strncmpi(lang,'ja',2)
        bool=true;
    else
        bool=false;
    end
end
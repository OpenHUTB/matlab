function runTaskAdvisor(this)





    ed=DAStudio.EventDispatcher;



    if ispc

        drawnow;
    end
    ed.broadcastEvent('MESleep');

    try

        needClearStartTime=false;
        if this.MAObj.StartTime==0
            this.MAObj.StartTime=now;
            needClearStartTime=true;
        end

        if isa(this,'ModelAdvisor.Task')
            if~this.Selected||(modeladvisorprivate('modeladvisorutil2','InMixProcedureGroupCase',this.getParent)&&~this.getParent.Selected)
                ed.broadcastEvent('MEWake');
                return
            end

            if isa(this.MAObj.ListExplorer,'DAStudio.Explorer')
                this.MAObj.ListExplorer.delete;
            end


            if strcmp(this.MAObj.TaskAdvisorRoot.ID,'com.mathworks.HDL.WorkflowAdvisor')...
                &&isa(this.NextInProcedureCallGraph,'ModelAdvisor.Task')
                this.reset;
            end


            this.MAObj.runCheck(this.Index,this.OverwriteHTML,this);
            this.updateStates('refreshME');
            redrawCurrentDialog(this);
            this.updateResultGUI;
        elseif isa(this,'ModelAdvisor.Group')
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            runTaskList={};


            [allChildren,PunderGchildrenObj]=getAllChildrenExceptPUG(this);

            extensiveIndices={};
            extensiveChildIdx=[];

            for i=1:length(allChildren)
                if allChildren{i}.Selected
                    runTaskList{end+1}=allChildren{i}.Index;%#ok<AGROW>

                    if strcmp(this.MAObj.CustomTARootID,'_modeladvisor_')&&...
                        ~isempty(allChildren{i}.Check)&&any(strcmp(allChildren{i}.Check.CallbackContext,{'SLDV','CGIR'}))
                        extensiveIndices{end+1}=allChildren{i}.Index;%#ok<AGROW>
                        extensiveChildIdx(end+1)=i;%#ok<AGROW>
                    end
                else
                    allChildren{i}.State=ModelAdvisor.CheckStatus.NotRun;
                end
            end

            if~isempty(extensiveIndices)&&~this.MAObj.CmdLine

                if~ispref('modeladvisor','removeExtensiveChecks')
                    addpref('modeladvisor','removeExtensiveChecks','ask');
                end
                if strcmp(getpref('modeladvisor','removeExtensiveChecks'),'Abort')
                    setpref('modeladvisor','removeExtensiveChecks','ask');
                end
                [choice,~]=uigetpref('modeladvisor',...
                'removeExtensiveChecks',...
                DAStudio.message('ModelAdvisor:engine:CmdAPIWarningDialogTitle'),...
                DAStudio.message('ModelAdvisor:engine:MAExtensiveAnalysisGroupCBWarn'),...
                {DAStudio.message('ModelAdvisor:engine:CmdAPIWarningDialogContinue'),DAStudio.message('ModelAdvisor:engine:CmdAPIWarningDialogAbort');},...
                'DefaultButton',DAStudio.message('ModelAdvisor:engine:CmdAPIWarningDialogAbort'));

                if strcmpi(choice,DAStudio.message('ModelAdvisor:engine:CmdAPIWarningDialogAbort'))
                    ed.broadcastEvent('MEWake');
                    return;
                end
            end

            this.MAObj.runCheck(runTaskList,this.OverwriteHTML,this);


            for i=1:length(PunderGchildrenObj)
                if PunderGchildrenObj{i}.Selected
                    PunderGchildrenObj{i}.runToFail;
                end
            end
            delete(sess);

            this.updateStates('refreshME');
            redrawCurrentDialog(this);
            this.updateResultGUI;
        end



        if isfield(this.MAObj.UserData,'globalTimer')&&...
            isvalid(this.MAObj.UserData.globalTimer)
            stop(this.MAObj.UserData.globalTimer);
            delete(this.MAObj.UserData.globalTimer);
        end


        parentObj=this.ParentObj;
        while isa(parentObj,'ModelAdvisor.Group')
            updateReportIfExist(this.MAObj,parentObj);
            parentObj=parentObj.ParentObj;
        end
    catch E

        if needClearStartTime
            this.MAObj.StartTime=0;
        end



        if isfield(this.MAObj.UserData,'globalTimer')&&...
            isvalid(this.MAObj.UserData.globalTimer)
            stop(this.MAObj.UserData.globalTimer);
            delete(this.MAObj.UserData.globalTimer);
        end

        ed.broadcastEvent('MEWake');
        rethrow(E);
    end


    if needClearStartTime
        this.MAObj.StartTime=0;
    end

    ed.broadcastEvent('MEWake');

    if this.MAObj.isSleeping
        this.MAObj.setStatus(DAStudio.message('ModelAdvisor:engine:BackgroundRunInitializing'));
        return;
    end

    if(isa(this,'ModelAdvisor.Group')&&this.LaunchReport)||(isjava(this.MAObj.BrowserWindow)&&this.MAObj.BrowserWindow.isShowing)
        this.viewReport('');
    end


    function redrawCurrentDialog(this)


        Advisor.Utils.refreshCurrentMATreeNodeDialog(this.MAObj);


        function updateReportIfExist(maobj,taskNode)
            WorkDir=maobj.getWorkDir;
            reportName=modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',taskNode,WorkDir);
            if exist(reportName,'file')
                maobj.generateReport(taskNode);
            end

            function[childrenObj,PunderGchildrenObj]=getAllChildrenExceptPUG(this)



                PunderGchildrenObj={};
                if isa(this,'ModelAdvisor.Task')
                    childrenObj={this};
                else
                    childrenObj={};
                    for i=1:length(this.ChildrenObj)
                        if isa(this.ChildrenObj{i},'ModelAdvisor.Procedure')&&~isa(this,'ModelAdvisor.Procedure')


                            PunderGchildrenObj{end+1}=this.ChildrenObj{i};%#ok<AGROW>
                        else
                            [subchildrenObj,subPunderGchildrenObj]=getAllChildrenExceptPUG(this.ChildrenObj{i});
                            childrenObj=[childrenObj,subchildrenObj];%#ok<AGROW>
                            PunderGchildrenObj=[PunderGchildrenObj,subPunderGchildrenObj];%#ok<AGROW>
                        end
                    end
                end



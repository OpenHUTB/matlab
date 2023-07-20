function updateStates(this,state,varargin)







    if strcmp(state,'refreshME')
        loc_refreshME(this);
        return
    end

    if ischar(this.State)
        this.State=getStateFromString(this.State,this.Failed);
    end

    if ischar(state)
        failed=false;
        if isa(this,'ModelAdvisor.Task')
            failed=modeladvisorprivate('modeladvisorutil2','IsErrorFatal',this);
        end
        state=getStateFromString(state,failed);
    end


    oldstate=this.State;
    this.State=state;

    oldDisplayIcon=this.StateIcon;
    newDisplayIcon=this.getDisplayIcon;
    this.StateIcon=newDisplayIcon;































    if isa(this,'ModelAdvisor.Task')&&isa(this.NextInProcedureCallGraph,'ModelAdvisor.Task')
        if(state~=oldstate)||~strcmp(newDisplayIcon,oldDisplayIcon)||this.Failed~=modeladvisorprivate('modeladvisorutil2','IsErrorFatal',this)...
            ||this.ShowCheckbox||this.NextInProcedureCallGraph(1).ShowCheckbox


            if this.ShowCheckbox&&~this.Selected
                if isa(this.PreviousInProcedureCallGraph,'ModelAdvisor.Task')
                    this.PreviousInProcedureCallGraph(1).updateStates(this.PreviousInProcedureCallGraph(1).State);
                end
            else
                if modeladvisorprivate('modeladvisorutil2','shallWeStopatFailOntheNode',this,this.Check)...
                    ||(this.State==ModelAdvisor.CheckStatus.NotRun)
                    loc_deselectFollowingInProcedureCallGraph(this);
                else
                    for i=1:length(this.NextInProcedureCallGraph)
                        nextNode=this.NextInProcedureCallGraph(i);
                        while isa(nextNode,'ModelAdvisor.Task')&&(nextNode.ShowCheckbox&&~nextNode.Selected)
                            nextNode=nextNode.NextInProcedureCallGraph;
                        end

                        if isa(nextNode,'ModelAdvisor.Task')
                            nextNode.Enable=true;
                            nextNode.changeSelectionStatus(true);
                            nextNode.updateStates(ModelAdvisor.CheckStatus.NotRun);
                        end
                    end
                end
            end
        end
    end


    if isa(this,'ModelAdvisor.Task')
        this.Failed=modeladvisorprivate('modeladvisorutil2','IsErrorFatal',this);
    elseif isa(this,'ModelAdvisor.Group')

        if isa(this.MAObj,'Simulink.ModelAdvisor')
            this.RunTime=this.MAObj.RunTime;
        end
        update_group_status(this);


















    end


    this.StateIcon=this.getDisplayIcon;











    if isa(this.ParentObj,'ModelAdvisor.Node')&&~strcmp(this.ParentObj.ID,'SysRoot')
        parent_state=calculate_parent_state(this);
        this.ParentObj.updateStates(parent_state,varargin);
    else


        if nargin<=2
            loc_refreshME(this);
        end
    end


    function loc_deselectFollowingInProcedureCallGraph(this)
        if isa(this.NextInProcedureCallGraph,'ModelAdvisor.Task')
            for i=1:length(this.NextInProcedureCallGraph)
                if~(this.NextInProcedureCallGraph(i).ShowCheckbox&&~this.NextInProcedureCallGraph(i).Selected)
                    if~isempty(this.NextInProcedureCallGraph(i).check)
                        this.NextInProcedureCallGraph(i).check.setStatus(ModelAdvisor.CheckStatus.NotRun);
                    end
                    this.NextInProcedureCallGraph(i).updateStates(ModelAdvisor.CheckStatus.NotRun);
                    if~this.NextInProcedureCallGraph(i).ShowCheckbox
                        this.NextInProcedureCallGraph(i).changeSelectionStatus(false);
                        this.NextInProcedureCallGraph(i).Enable=false;
                    end
                end
                loc_deselectFollowingInProcedureCallGraph(this.NextInProcedureCallGraph(i));
            end
        end

        function loc_refreshME(this)

            if~isa(this.MAObj,'Simulink.ModelAdvisor')||~isa(this.MAObj.MAExplorer,'DAStudio.Explorer')
                return
            end

            fptme_WF=this.MAObj.MAExplorer;


            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',fptme_WF.getRoot);
            ed.broadcastEvent('PropertyChangedEvent',fptme_WF.getRoot);


            if~isempty(fptme_WF)
                if~isempty(fptme_WF.getDialog)
                    fptme_WF.getDialog.refresh;
                end
            end

            function update_group_status(this)
                this.Failed=false;
                ch=this.getChildren;
                if~isempty(ch)
                    InTriState=0;
                    Selected=0;
                    Deselected=0;
                    for i=1:length(ch)
                        if ch(i).Selected&&ch(i).Failed
                            this.Failed=true;
                        end
                        if ch(i).Selected
                            Selected=Selected+1;
                        else
                            Deselected=Deselected+1;
                        end
                        if ch(i).InTriState
                            InTriState=InTriState+1;
                        end
                    end

                    if(Selected>0&&Deselected>0)||InTriState>0
                        if~modeladvisorprivate('modeladvisorutil2','InMixProcedureGroupCase',this)
                            this.InTriState=true;
                        end
                    else
                        if~modeladvisorprivate('modeladvisorutil2','InMixProcedureGroupCase',this)
                            this.InTriState=false;
                        end
                    end




                    if Selected>0||InTriState>0
                        newSelectStatus=true;
                    else
                        newSelectStatus=false;
                    end
                    if newSelectStatus~=this.Selected
                        if~modeladvisorprivate('modeladvisorutil2','InMixProcedureGroupCase',this)
                            this.Selected=newSelectStatus;
                        end
                    end
                end
























                function parent_state=calculate_parent_state(this)

                    ch=this.ParentObj.getChildren;
                    parent_state=ModelAdvisor.CheckStatus.NotRun;
                    arr_status=[];
                    for i=1:length(ch)
                        if ch(i).Selected
                            if isa(ch(i),'ModelAdvisor.Task')&&~isempty(ch(i).check)
                                arr_status=[arr_status;ch(i).check.status];
                            else


                                if ischar(ch(i).state)
                                    ch(i).state=getStateFromString(ch(i).state,ch(i).failed);
                                end
                                arr_status=[arr_status;ch(i).state];
                            end
                        end
                    end

                    if~isempty(arr_status)
                        parent_state=ModelAdvisor.CheckStatusUtil.getParentStatus(arr_status);
                    end


















                    function state=getStateFromString(strState,failed)

                        if(strcmp(strState,'Fail')&&~failed)
                            state=ModelAdvisor.CheckStatus.Warning;
                        else
                            state=ModelAdvisor.CheckStatusUtil.getStatusFromString(strState);
                        end

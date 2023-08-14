function cm=getContextMenu(this,~)




    persistent menu;

    if(~isempty(this.MAObj))

        if~isempty(menu)&&ishandle(menu)
            menu.delete;
        end

        me=this.MAObj.MAExplorer;
        am=DAStudio.ActionManager;
        cm=am.createPopupMenu(me);

        if strcmpi(this.MAObj.CustomTARootID,'com.mathworks.Simulink.MdlTransformer.MdlTransformer')&&...
            ~strcmpi(this.MAObj.CustomTARootID,this.getID)
            return;
        end

        if strcmpi(this.MAObj.CustomTARootID,'com.mathworks.Simulink.CloneDetection.CloneDetection')&&...
            ~strcmpi(this.MAObj.CustomTARootID,this.getID)
            return;
        end

        menuStruct=modeladvisorprivate('modeladvisorutil2','GetSelectMenuForTaskAdvsiorNode',this);
        if isfield(this.MAObj.MEMenus,'run')&&isa(this.MAObj.MEMenus.run,'DAStudio.Action')
            runTaskAdvisorCB=this.MAObj.MEMenus.run;
        else
            runTaskAdvisorCB=am.createAction(me,'text',menuStruct.runTaskAdvisormsg,'callback','ModelAdvisor.Node.run;','enabled',menuStruct.runTaskAdvisorEnable);
        end
        if isfield(this.MAObj.MEMenus,'Select')&&isa(this.MAObj.MEMenus.Select,'DAStudio.Action')
            selectCB=this.MAObj.MEMenus.Select;
        else
            selectCB=am.createAction(me,'text',menuStruct.selectmsg,'callback','ModelAdvisor.Node.select;','enabled',menuStruct.selectEnable);
        end
        if isfield(this.MAObj.MEMenus,'Deselect')&&isa(this.MAObj.MEMenus.Deselect,'DAStudio.Action')
            deselectCB=this.MAObj.MEMenus.Deselect;
        else
            deselectCB=am.createAction(me,'text',menuStruct.deselectmsg,'callback','ModelAdvisor.Node.deselect;','enabled',menuStruct.deselectEnable);
        end
        if menuStruct.runTaskAdvisorVisible
            cm.addMenuItem(runTaskAdvisorCB);
        end
        if menuStruct.run2failureVisible
            if isfield(this.MAObj.MEMenus,'runToFail')&&isa(this.MAObj.MEMenus.runToFail,'DAStudio.Action')
                run2failureCB=this.MAObj.MEMenus.runToFail;
            else
                run2failureCB=am.createAction(me,'text',menuStruct.run2failuremsg,'callback','ModelAdvisor.Node.runtofailure;','enabled',menuStruct.run2failureEnable);
            end
            cm.addMenuItem(run2failureCB);
        end
        if~isa(this,'ModelAdvisor.Procedure')&&isa(this.getParent,'ModelAdvisor.Procedure')
            if isfield(this.MAObj.MEMenus,'runToHere')&&isa(this.MAObj.MEMenus.runToHere,'DAStudio.Action')
                runToHereCB=this.MAObj.MEMenus.runToHere;
            else
                runToHereCB=am.createAction(me,'text',DAStudio.message('Simulink:tools:MARunToSelectedTask'),'callback','ModelAdvisor.Node.runtohere;','enabled','on');
                this.MAObj.MEMenus.runToHere=runToHereCB;
            end
            cm.addMenuItem(runToHereCB);
            cm.addSeparator;
        end
        if menuStruct.continueVisible
            if isfield(this.MAObj.MEMenus,'continue')&&isa(this.MAObj.MEMenus.continue,'DAStudio.Action')
                continueCB=this.MAObj.MEMenus.continue;
            else
                continueCB=am.createAction(me,'text',menuStruct.continuemsg,'callback','ModelAdvisor.Node.continuerun;','enabled',menuStruct.continueEnable);
            end
            cm.addMenuItem(continueCB);
        end
        if menuStruct.resetVisible
            if isfield(this.MAObj.MEMenus,'Reset')&&isa(this.MAObj.MEMenus.Reset,'DAStudio.Action')
                resetCB=this.MAObj.MEMenus.Reset;
            else
                resetCB=am.createAction(me,'text',menuStruct.resetmsg,'callback','ModelAdvisor.Node.resetgui;','enabled',menuStruct.resetEnable);
            end
            cm.addMenuItem(resetCB);
        end
        cm.addSeparator;
        if menuStruct.selectVisible
            cm.addMenuItem(selectCB);
        end
        if menuStruct.deselectVisible
            cm.addMenuItem(deselectCB);
        end
        if isfield(this.MAObj.MEMenus,'getCheckID')&&isa(this.MAObj.MEMenus.getCheckID,'DAStudio.Action')
            checkID=this.MAObj.MEMenus.getCheckID;
        else
            checkID=am.createAction(me,'text',menuStruct.selectmsg,'callback','ModelAdvisor.Node.select;','enabled',menuStruct.selectEnable);
        end
        cm.addSeparator;
        if(menuStruct.getCheckIDVisible)
            checkID.enabled=menuStruct.getCheckIDEnable;
        end
        cm.addMenuItem(checkID);

        if isfield(this.MAObj.MEMenus,'getTaskID')&&isa(this.MAObj.MEMenus.getCheckID,'DAStudio.Action')
            TaskID=this.MAObj.MEMenus.getTaskID;
            if(menuStruct.getTaskIDVisible)
                TaskID.enabled=menuStruct.getTaskIDEnable;
            end
            cm.addMenuItem(TaskID);
        end


        if~isempty(this.CSHParameters)
            cm.addSeparator;
            if isfield(this.MAObj.MEMenus,'CSHHelp')&&isa(this.MAObj.MEMenus.CSHHelp,'DAStudio.Action')
                helpCB=this.MAObj.MEMenus.CSHHelp;
            else
                helpCB=am.createAction(me,'text',DAStudio.message('Simulink:tools:MAWhatsThis'),'callback','ModelAdvisor.Node.opencsh;','enabled','on');
                this.MAObj.MEMenus.CSHHelp=helpCB;
            end
            cm.addMenuItem(helpCB);
        end
        menu=cm;
    end


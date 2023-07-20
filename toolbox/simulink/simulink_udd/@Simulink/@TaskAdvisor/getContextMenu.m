function cm=getContextMenu(this,selectedHandles)



    persistent menu;

    if(~isempty(this.MAObj))

        if~isempty(menu)&&ishandle(menu)
            menu.delete;
        end

        me=this.MAObj.MAExplorer;
        am=DAStudio.ActionManager;
        cm=am.createPopupMenu(me);
        menuStruct=modeladvisorprivate('modeladvisorutil2','GetSelectMenuForTaskAdvsiorNode',this);
        runTaskAdvisorCB=am.createAction(me,'text',menuStruct.runTaskAdvisormsg,'callback','Simulink.TaskAdvisor.run;','enabled',menuStruct.runTaskAdvisorEnable);
        selectCB=am.createAction(me,'text',menuStruct.selectmsg,'callback','Simulink.TaskAdvisor.select;','enabled',menuStruct.selectEnable);
        deselectCB=am.createAction(me,'text',menuStruct.deselectmsg,'callback','Simulink.TaskAdvisor.deselect;','enabled',menuStruct.deselectEnable);
        if menuStruct.runTaskAdvisorVisible
            cm.addMenuItem(runTaskAdvisorCB);
            cm.addSeparator;
        end
        if menuStruct.selectVisible
            cm.addMenuItem(selectCB);
        end
        if menuStruct.deselectVisible
            cm.addMenuItem(deselectCB);
        end
        if~isempty(this.CSHParameters)
            cm.addSeparator;
            helpCB=am.createAction(me,'text',DAStudio.message('Simulink:tools:MAWhatsThis'),'callback','Simulink.TaskAdvisor.opencsh;','enabled','on');
            cm.addMenuItem(helpCB);
        end
        menu=cm;
    end


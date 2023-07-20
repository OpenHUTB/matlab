function success=changeSelectionStatus(this,newstatus)





    success=false;

    if this.Visible&&this.Enable

        if this.MACIndex~=0
            if this.ByTaskMode
                this.MAObj.updateCheckForTask(this.MACIndex,newstatus);
            else
                this.MAObj.updateCheck(this.MACIndex,newstatus);
            end
        elseif this.MATIndex~=0
            this.MAObj.updateTask(this.MATIndex,newstatus);
        end

        for i=1:length(this.ChildrenObj)
            childsuccess=changeSelectionStatus(this.ChildrenObj{i},newstatus);
            if~childsuccess
                success=false;
            end
        end
        this.Selected=newstatus;
        success=true;


        dlgs=DAStudio.ToolRoot.getOpenDialogs(this);
        if isa(dlgs,'DAStudio.Dialog')
            dlgs.restoreFromSchema;
        end

        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyChangedEvent',this);
        this.updateStates(this.State,'fastmode');
    else
        success=false;
    end

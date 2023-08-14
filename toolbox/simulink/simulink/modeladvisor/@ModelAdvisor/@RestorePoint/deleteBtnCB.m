function deleteBtnCB(this,dialogHandle)




    if isa(this.MAObj,'Simulink.ModelAdvisor')
        shlist=this.MAObj.getRestorePointList;
        if isnumeric(this.SelectedLineIndex)&&~isempty(this.SelectedLineIndex)&&...
            (this.SelectedLineIndex+1<=length(shlist))
            selectedSnapshot=shlist{this.SelectedLineIndex+1};
            this.MAObj.deleteRestorePoint(selectedSnapshot.name);

            dlgs=DAStudio.ToolRoot.getOpenDialogs(this);
            if isa(dlgs,'DAStudio.Dialog')
                dlgs.restoreFromSchema;
            end
        end
    end

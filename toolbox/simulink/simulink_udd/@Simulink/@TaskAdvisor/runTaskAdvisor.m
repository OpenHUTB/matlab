function runTaskAdvisor(this)





    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('MESleep');

    try
        if~isempty(this.MAC)
            if~this.Selected
                return
            end

            if isa(this.MAObj.ListExplorer,'DAStudio.Explorer')
                this.MAObj.ListExplorer.delete;
            end
            this.MAObj.runCheck(this.MAC,this.OverwriteHTML,this);
            if this.MAObj.CheckCellArray{this.MACIndex}.Success
                this.updateStates('Pass');
            else
                this.updateStates('Fail');
            end
            this.WaiveFailure=false;


            dlgs=DAStudio.ToolRoot.getOpenDialogs(this);
            if isa(dlgs,'DAStudio.Dialog')
                dlgs.restoreFromSchema;
            end
        elseif~isempty(this.ChildrenObj)
            runCheckList={};
            allChildren=getAllChildren(this);
            for i=1:length(allChildren)
                if allChildren{i}.Selected
                    runCheckList{end+1}=allChildren{i}.MAC;%#ok<AGROW>
                    allChildren{i}.WaiveFailure=false;
                else
                    allChildren{i}.State='None';
                end
            end
            this.MAObj.runCheck(runCheckList,this.OverwriteHTML,this);
            for i=1:length(allChildren)
                if allChildren{i}.Selected
                    if this.MAObj.CheckCellArray{allChildren{i}.MACIndex}.Success
                        allChildren{i}.updateStates('Pass','fastmode');
                    else
                        allChildren{i}.updateStates('Fail','fastmode');
                    end
                end

            end
            this.updateStates('refreshME');

        end
    catch E
        ed.broadcastEvent('MEWake');
        rethrow(E);
    end

    ed.broadcastEvent('MEWake');


    if this.LaunchReport||(isjava(this.MAObj.BrowserWindow)&&this.MAObj.BrowserWindow.isVisible)
        this.viewReport;
    end
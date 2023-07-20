function result=updateTable(this,propValues)
    result=[];
    window=Advisor.UIService.getInstance.getWindowById('ExclusionEditor',this.windowId);

    if~this.isTableDataValid
        this.getTableData();
    end

    if iscell(propValues.checkIDs)
        checkStr=['{',strjoin(propValues.checkIDs,', '),'}'];
    else
        checkStr=propValues.checkIDs;
    end

    this.TableData{propValues.rowNum}{4}=struct('checks',checkStr,'rowNum',propValues.rowNum);

    if window.isOpen()
        this.refreshUI();
    else
        window.open();
    end
    window.bringToFront();
    this.setDialogDirty();
end
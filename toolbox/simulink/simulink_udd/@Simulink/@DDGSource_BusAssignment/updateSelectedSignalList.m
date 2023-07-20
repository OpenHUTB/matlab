function updateSelectedSignalList(this,dlg,entries)





    entriesStr=this.cellArr2Str(entries);
    this.mAssignedSignals=entriesStr;
    dlg.setUserData('assignedList',entries);
end


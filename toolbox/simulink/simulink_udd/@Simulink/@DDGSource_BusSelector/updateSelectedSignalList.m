function updateSelectedSignalList(this,dlg,entries)





    entriesStr=this.cellArr2Str(entries);
    this.mOutputSignals=entriesStr;
    dlg.setUserData('outputsList',entries);
end


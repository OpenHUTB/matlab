function updateSelectedSignalList(this,dlg,entries)





    entriesStr=this.cellArr2Str(entries);
    this.state.InputsString=entriesStr;
    customNames=dlg.getWidgetValue('MatchInputsString');
    if customNames
        this.state.Inputs=entriesStr;
    else
        this.state.Inputs=num2str(length(entries));
    end
    dlg.setUserData('signalsList',entries);
end

function refresh_hook(this,dlg,hierarchy,forceRefresh)






    if forceRefresh
        setBusItem(this,hierarchy);
        this.signalSelector.TCPeer.update;
    end

    [~,entries]=this.retrieveSelection(dlg);
    entries=validateSelections(this,this.cleanQuestionMarks(entries),hierarchy);
    this.updateSelectedSignalList(dlg,entries);

    dlg.refresh;


    this.updateSelection(dlg,this.signalSelector);
    this.hiliteSignalInList(dlg);

end

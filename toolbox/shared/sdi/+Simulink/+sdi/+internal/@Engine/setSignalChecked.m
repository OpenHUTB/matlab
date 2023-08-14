function setSignalChecked(this,id,value)
    if~this.isEmptySignal(id)
        runApp=this.sigRepository.getRunAppAsString(...
        this.getSignalRunID(id));
        if~strcmp(runApp,'sdi')&&~strcmp(runApp,'siganalyzer')

            return;
        end
        this.setChecked(id,value);
        notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
        id,value,'checked'));
        this.dirty=true;
    end
end
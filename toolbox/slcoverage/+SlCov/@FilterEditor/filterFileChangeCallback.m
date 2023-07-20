function filterFileChangeCallback(this,dlg,filterFileNameTag)




    newFile=dlg.getWidgetValue(filterFileNameTag);

    if~isempty(newFile)
        this.lastFilterElement.fileName=this.fileName;
        this.fileName=newFile;
        this.load(newFile);
        this.saveToModel=false;
        this.hasUnappliedChanges=true;
        dlg.enableApplyButton(true);
        dlg.refresh;
    end

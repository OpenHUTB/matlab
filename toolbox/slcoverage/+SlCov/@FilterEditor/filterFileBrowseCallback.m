function filterFileBrowseCallback(this,dlg)




    ext='*.cvf';
    text=getString(message('Slvnv:simcoverage:filterEditor:PickFilterFile'));

    newFile=SlCov.FilterEditor.browseCallback(this.fileName,ext,text);

    if~isempty(newFile)
        this.lastFilterElement.fileName=this.fileName;
        this.needSave=true;
        this.fileName=newFile;
        this.load(newFile);
        this.saveToModel=false;
        this.hasUnappliedChanges=true;
        dlg.enableApplyButton(true);
        dlg.refresh;
    end

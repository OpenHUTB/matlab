function onBrowseOutputFolder(this,dlg)





    folder=uigetdir;

    if(ischar(folder))
        this.HasChangedOutputFolder=true;
        this.OutputFolder=folder;

        dlg.refresh;
    end

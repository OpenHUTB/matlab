function onChangeOutputFolder(this,dlg)





    this.HasChangedOutputFolder=true;


    try
        this.BuildInfo.setOutputFolder(this.OutputFolder);
    catch ME
        this.Status=ME.message;
    end


    dlg.refresh;

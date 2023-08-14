function result=saveToModel(this)




    result=[];

    this.updateBackend();

    exclusionsObj=CloneDetector.Exclusions();
    manager=exclusionsObj.getCloneDetectionFilterManager(this.model);



    this.isSaveToSlx=true;
    manager.saveToFile(CloneDetector.Utils.getFilterFilePath(this.model));


    save_system(this.model);
    this.updateDialogForAction(this.UpdateDialogAction.Save,this.model);
    this.setExternalFilePath('');
end



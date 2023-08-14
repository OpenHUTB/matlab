




function initializeModelGen(this)

    createBackupModel(this);

    for m=1:length(this.fXformedLibs)
        load_system([this.fXformDir,this.fPrefix,this.fXformedLibs{m}]);
    end
    warning('off','Simulink:modelReference:ModelNotFoundWithBlockName');
    for m=1:length(this.fRefMdls)
        load_system([this.fXformDir,this.fPrefix,this.fRefMdls{m}]);
    end
    warning('on','Simulink:modelReference:ModelNotFoundWithBlockName');

    if(this.fOpenXformModel)
        open_system([this.fXformDir,this.fPrefix,this.fMdl]);
    else
        load_system([this.fXformDir,this.fPrefix,this.fMdl]);
    end

end




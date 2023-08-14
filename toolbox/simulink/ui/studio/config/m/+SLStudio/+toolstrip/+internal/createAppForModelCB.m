



function createAppForModelCB(cbinfo)
    modelName=SLStudio.Utils.getModelName(cbinfo);
    dlgSrc=simulink.compiler.internal.GenAppDialog(modelName);
    simulink.compiler.internal.showDialog(dlgSrc);
end

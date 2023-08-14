function[showInSDI,saveToFile,overwriteFile]=getSimDiagnosticsOptions(modelName)





    hCS=getActiveConfigSet(modelName);
    valStore=DAStudio.message('codertarget:ui:SimDiagShowInSDIStorage');
    showInSDI=isequal(...
    codertarget.data.getParameterValue(hCS,valStore),1);
    valStore=DAStudio.message('codertarget:ui:SimDiagSaveToFileStorage');
    saveToFile=isequal(...
    codertarget.data.getParameterValue(hCS,valStore),1);
    valStore=DAStudio.message('codertarget:ui:SimDiagOverwriteFileStorage');
    overwriteFile=isequal(...
    codertarget.data.getParameterValue(hCS,valStore),1);
end
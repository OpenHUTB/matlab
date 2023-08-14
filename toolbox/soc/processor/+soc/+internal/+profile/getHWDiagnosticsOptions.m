function[showInSDI,saveToFile,overwriteFile]=getHWDiagnosticsOptions(modelName)





    hCS=getActiveConfigSet(modelName);
    valStore=DAStudio.message('codertarget:ui:HWDiagShowInSDIStorage');
    showInSDI=isequal(...
    codertarget.data.getParameterValue(hCS,valStore),1);
    valStore=DAStudio.message('codertarget:ui:HWDiagSaveToFileStorage');
    saveToFile=isequal(...
    codertarget.data.getParameterValue(hCS,valStore),1);
    valStore=DAStudio.message('codertarget:ui:HWDiagOverwriteFileStorage');
    overwriteFile=isequal(...
    codertarget.data.getParameterValue(hCS,valStore),1);
end
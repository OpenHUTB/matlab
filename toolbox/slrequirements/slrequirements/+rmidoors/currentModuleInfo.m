function[currentModule,errMsg]=currentModuleInfo()

    try
        currentModuleId=rmiref.DoorsUtil.getCurrentDoc();
        currentModuleName=rmidoors.getModuleAttribute(currentModuleId,'Name');
        currentModule=sprintf('%s (%s)',currentModuleId,currentModuleName);
        errMsg='';
    catch me
        errMsg=me.message;
        currentModule='';
    end

end
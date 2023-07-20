function isProf=isProfilePIL(modelName)











    modelName=convertStringsToChars(modelName);

    targetInfo=getTgtPrefInfo(modelName);
    isARM=~isempty(strfind(targetInfo.chipInfo.deviceID,'ARM'));
    isIntel=~isempty(strfind(targetInfo.chipInfo.deviceID,'Intel'));
    isAMD=~isempty(strfind(targetInfo.chipInfo.deviceID,'AMD'));
    isRTOSNone=isequal(targetInfo.RTOS,'None');

    isPIL=linkfoundation.pil.isPILCodeGeneration(modelName)||...
    linkfoundation.pil.isLibCodeGeneration(modelName);



    isProf=isPIL&&~(isARM&&isRTOSNone)&&~isIntel&&~isAMD;



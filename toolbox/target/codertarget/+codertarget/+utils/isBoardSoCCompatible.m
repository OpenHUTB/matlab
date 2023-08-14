function out=isBoardSoCCompatible(boardName)





    import codertarget.targethardware.*;
    targetHardwareInfo=getTargetHardwareFromName(boardName);




    out=any(cellfun(@(x)any(x),{targetHardwareInfo.ESBCompatible}));

end
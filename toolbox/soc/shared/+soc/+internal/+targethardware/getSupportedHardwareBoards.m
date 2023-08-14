function out=getSupportedHardwareBoards()




    out=unique([...
    codertarget.targethardware.getSupportedHardwareBoardsForID(codertarget.targethardware.BaseProductID.SOC),...
    codertarget.internal.getTargetHardwareNamesForSoC()]);
end
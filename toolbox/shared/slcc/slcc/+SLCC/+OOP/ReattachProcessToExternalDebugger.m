function ReattachProcessToExternalDebugger(checksum,isOOP)

    exePID='';
    if isOOP
        exePID=slcc('getExePID',checksum);
    end
    SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().reattachProcessToDebugger(char(exePID),isOOP);

end
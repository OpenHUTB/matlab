function family=getFamily(sys)


    boardName=get_param(sys,'HardwareBoard');
    fpgaParams=soc.internal.getCustomBoardParams(boardName);
    if isempty(fpgaParams)
        family='';
    else
        family=fpgaParams.fdevObj.FPGAFamily;
    end
end
function out=shouldESBPluginBeAttached(hCS)






    out=false;
    if~hCS.isValidParam('CoderTargetData')
        return
    end
    targetInfo=codertarget.targethardware.getTargetHardware(hCS);
    board=codertarget.data.getParameterValue(hCS,'TargetHardware');

    switch(targetInfo.ESBCompatible)
    case 1

        socPkgsBoards=codertarget.internal.getHardwareBoardsForInstalledSpPkgs('soc');
        out=ismember(board,socPkgsBoards);
    case 2
        out=true;
    case 3

        out=codertarget.utils.isMdlConfiguredForSoC(hCS);
    otherwise
        out=false;
    end

end

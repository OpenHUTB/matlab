function[linkPjtGenInfo,schedPjtGenInfo]=getTimerMode_C5x(linkPjtGenInfo,schedPjtGenInfo)





    tgtPrefInfo=getTgtPrefInfo(linkPjtGenInfo.modelName);
    if strcmp(tgtPrefInfo.chipInfo.subFamily,'5501')||strcmp(tgtPrefInfo.chipInfo.subFamily,'5502')
        schedPjtGenInfo.timerOpt='64bit-timer';
    else
        schedPjtGenInfo.timerOpt='16bit-timer';
    end



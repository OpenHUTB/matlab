function delayComp=getIntDelayEnabledResettableComp(hN,hInSignals,hOutSignals,hEnbSignals,hRstSignal,delayNumber,compName,ic,resettype,isDefaultHwSemantics,desc,slHandle)













    if(nargin<12)
        slHandle=-1;
    end

    if(nargin<11)
        desc='';
    end

    if(nargin<10)
        isDefaultHwSemantics=true;
    end
    if(nargin<9)
        resettype='';
    end

    if(nargin<8)
        ic=0;
    end

    if(nargin<7)
        compName='intdelay';
    end

    if isDefaultHwSemantics
        hN.setHasSLHWFriendlySemantics(true);
    end

    delayComp=pircore.getIntDelayEnabledResettableComp(hN,hInSignals,hOutSignals,delayNumber,compName,ic,resettype,hEnbSignals,hRstSignal,desc,slHandle);



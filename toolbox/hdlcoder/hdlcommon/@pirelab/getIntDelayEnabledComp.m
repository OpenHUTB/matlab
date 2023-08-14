function delayComp=getIntDelayEnabledComp(hN,hInSignals,hOutSignals,hEnbSignals,delayNumber,compName,ic,resettype,isDefaultHwSemantics,desc,slHandle)










    if(nargin<11)
        slHandle=-1;
    end

    if(nargin<10)
        desc='';
    end

    if(nargin<9)
        isDefaultHwSemantics=true;
    end

    if(nargin<8)
        resettype='';
    end

    if(nargin<7)
        ic=0;
    end

    if(nargin<6)
        compName='intdelay';
    end

    if isDefaultHwSemantics
        hN.setHasSLHWFriendlySemantics(true);
    end

    delayComp=pircore.getIntDelayEnabledResettableComp(hN,hInSignals,hOutSignals,...
    delayNumber,compName,ic,resettype,hEnbSignals,'',desc,slHandle);


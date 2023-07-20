function delayComp=getIntDelayEnabledComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,hEnbSignals,desc,slHandle)






    if(nargin<10)
        slHandle=-1;
    end

    if(nargin<9)
        desc='';
    end

    if(nargin<8)
        hEnbSignals='';
    end

    if(nargin<7)
        resettype='';
    end

    if(nargin<6)
        ic='';
    end

    if(nargin<5)
        compName='intdelay';
    end

    delayComp=pireml.getIntDelayEnabledResettableComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,ic,resettype,hEnbSignals,'',desc,slHandle);
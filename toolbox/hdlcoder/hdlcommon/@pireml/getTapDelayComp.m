function cgirComp=getTapDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,initVal,delayOrder,includeCurrent,resettype)






    if(nargin<9)
        resettype=false;
    end

    if(nargin<8)
        includeCurrent=false;
    end

    if(nargin<7)
        delayOrder=true;
    end

    if(nargin<6)
        initVal=0;
    end

    if(nargin<5)
        compName='tapdelay';
    end

    cgirComp=pireml.getTapDelayEnabledResettableComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName,initVal,delayOrder,includeCurrent,resettype);

end

function counterComp=getCounterLimitedComp(hN,hOutSignal,count_limit,outputRate,...
    compName,ic,limitedCounterOptimize,clkEn)















    useCore=true;
    if(nargin<8)
        clkEn='';
    else
        useCore=false;
    end

    if(nargin<7)
        limitedCounterOptimize=false;
    elseif(limitedCounterOptimize)
        useCore=false;
    end

    if(nargin<6)
        ic=pirelab.getTypeInfoAsFi(hOutSignal.Type);
    elseif(ic~=0)
        useCore=false;
    end

    if(nargin<5)
        compName='counter';
    end

    if(nargin<4)
        outputRate=0;
    elseif useCore
        hOutSignal.SimulinkRate=outputRate;
    end

    if useCore
        counterComp=pircore.getCounterLimitedComp(hN,hOutSignal,count_limit,compName);
    else
        counterComp=pireml.getCounterLimitedComp(hN,hOutSignal,count_limit,outputRate,compName,ic,limitedCounterOptimize,clkEn);
    end

end



function counterComp=getCounterLimitedComp(hN,hOutSignal,count_limit,outputRate,compName,ic,limitedCounterOptimize,clkEn)















    if(nargin<8)
        clkEn='';
    end

    if(nargin<7)
        limitedCounterOptimize=false;
    end

    if(nargin<6)
        ic=pirelab.getTypeInfoAsFi(hOutSignal.Type);
    end

    if(nargin<5)
        compName='counter';
    end

    if(nargin<4)
        outputRate=0;
    end


    counterComp=pireml.getCounterComp(...
    'Network',hN,...
    'OutputSignal',hOutSignal,...
    'OutputSimulinkRate',outputRate,...
    'Name',compName,...
    'InitialValue',ic,...
    'CountToValue',count_limit,...
    'LimitedCounterOptimize',limitedCounterOptimize,...
    'ClockEnableSignal',clkEn);

end



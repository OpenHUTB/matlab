function counterComp=getCounterFreeRunningComp(hN,hOutSignal,outputRate,compName,ic,clkEn)



    if(nargin<6)
        clkEn='';
    end

    if(nargin<5)
        ic=pirelab.getTypeInfoAsFi(hOutSignal.Type);
    end

    if(nargin<4)
        compName='counter';
    end

    if(nargin<3)
        outputRate=0;
    end


    counterComp=pireml.getCounterComp(...
    'Network',hN,...
    'OutputSignal',hOutSignal,...
    'OutputSimulinkRate',outputRate,...
    'Name',compName,...
    'InitialValue',ic,...
    'ClockEnableSignal',clkEn);
end



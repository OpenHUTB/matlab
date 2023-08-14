function counterComp=getCounterEnabledComp(hN,hOutSignal,hEnbSignals,compName,ic)




    if(nargin<5)
        ic=pirelab.getTypeInfoAsFi(hOutSignal.Type);
    end

    if(nargin<4)
        compName='counter';
    end

    if(nargin<3)
        hEnbSignals=[];
    end


    outputRate=hEnbSignals.SimulinkRate;


    counterComp=pireml.getCounterComp(...
    'Network',hN,...
    'OutputSignal',hOutSignal,...
    'OutputSimulinkRate',outputRate,...
    'Name',compName,...
    'InitialValue',ic,...
    'CountEnableSignal',hEnbSignals);

end

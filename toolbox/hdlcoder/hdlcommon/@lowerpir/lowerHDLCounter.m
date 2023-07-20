function hNewC=lowerHDLCounter(hN,hC)




    hOutSignal=hC.PirOutputSignals(1);

    if numel(hC.PirOutputSignals)==2
        hOutSignal1=hC.PirOutputSignals(2);
    else
        hOutSignal1='';
    end
    outputRate=hOutSignal.SimulinkRate;


    CInfo.LocalResetSignal=[];
    CInfo.LoadSignal=[];
    CInfo.LoadValueSignal=[];
    CInfo.CountEnableSignal=[];
    CInfo.CountDirectionSignal=[];

    hInSignals=hC.PirInputSignals;
    index=1;
    if hC.getResetPort
        CInfo.LocalResetSignal=hInSignals(index);
        index=index+1;
    end
    if hC.getLoadPort
        CInfo.LoadSignal=hInSignals(index);
        CInfo.LoadValueSignal=hInSignals(index+1);
        index=index+2;
    end
    if hC.getEnablePort
        CInfo.CountEnableSignal=hInSignals(index);
        index=index+1;
    end
    if hC.getDirectionPort
        CInfo.CountDirectionSignal=hInSignals(index);
    end


    [hNewC,hCounterComp]=pireml.getCounterComp(...
    'Network',hN,...
    'OutputSignal',hOutSignal,...
    'OutputSignal1',hOutSignal1,...
    'OutputSimulinkRate',outputRate,...
    'Name',hC.Name,...
    'LocalResetSignal',CInfo.LocalResetSignal,...
    'LoadSignal',CInfo.LoadSignal,...
    'LoadValueSignal',CInfo.LoadValueSignal,...
    'CountEnableSignal',CInfo.CountEnableSignal,...
    'CountDirectionSignal',CInfo.CountDirectionSignal,...
    'InitialValue',hC.getCountInit,...
    'StepValue',hC.getCountStep,...
    'CountToValue',hC.getCountMax,...
    'CountFromValue',hC.getCountFrom,...
    'CountType',hC.getCountType);




    if~isempty(hCounterComp)
        hCounterComp.copyTags(hC);
        hNewC.setInitialValueIsNotZero();
    end
end

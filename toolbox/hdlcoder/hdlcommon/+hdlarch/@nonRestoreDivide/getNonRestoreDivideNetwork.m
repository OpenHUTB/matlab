function hnonRestoreNet=getNonRestoreDivideNetwork(topNet,hInSignals,hOutSignals,divideInfo)





    hnonRestoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',divideInfo.networkName,...
    'InportNames',{'dividend_in','divisor_in'},...
    'InportTypes',[hInSignals(1).Type,hInSignals(2).Type],...
    'InportRates',[hInSignals(1).SimulinkRate,hInSignals(1).SimulinkRate],...
    'OutportNames',{'quotient'},...
    'OutportTypes',[hOutSignals(1).Type]);


    dividend_in=hnonRestoreNet.PirInputSignals(1);
    divisor_in=hnonRestoreNet.PirInputSignals(2);
    quotient=hnonRestoreNet.PirOutputSignals(1);

    if(divideInfo.firstInputSignDivide)

        inputSignals=[divisor_in,dividend_in];
    else
        inputSignals=[dividend_in,divisor_in];
    end


    hdlarch.nonRestoreDivide.getNonRestoreDivideComp(hnonRestoreNet,inputSignals,quotient,divideInfo);



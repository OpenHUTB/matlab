function biasComp=getBiasComp(hN,hInSignals,hOutSignals,biasVal,compName,ovMode)












    if nargin<6
        ovMode='Saturate';
    end
    if nargin<5
        compName='bias';
    end


    rndMode='Nearest';

    in1Type=hInSignals.Type;
    in1Dim=in1Type.getDimensions;

    asVector1D='off';
    if(numel(biasVal)>1)
        asVector1D='on';
    end
    ipSize=in1Dim;
    biasSize=numel(biasVal);

    biasConstName=[hdllegalname(compName),'_const_val'];
    if(biasSize>1)
        constSig=hN.addSignal(hOutSignals.Type,biasConstName);
    else
        if(ipSize>1)




            constSig=hN.addSignal(hOutSignals.Type.BaseType,biasConstName);
        else
            constSig=hN.addSignal(hOutSignals.Type,biasConstName);
        end
    end
    constSig.SimulinkRate=hInSignals.SimulinkRate;
    constComp=pirelab.getConstComp(hN,constSig,biasVal,biasConstName,asVector1D);

    biasComp=pirelab.getAddComp(hN,[hInSignals,constComp.PirOutputSignals],...
    hOutSignals,rndMode,ovMode,compName,hOutSignals.Type,'++');
    return
end

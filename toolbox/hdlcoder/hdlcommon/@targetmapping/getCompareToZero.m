function hOutSignal=getCompareToZero(hN,hInSignals,opName,outSigName,compName)
    baseType=hInSignals.Type;
    boolType=pir_boolean_t;

    constOut=hN.addSignal(baseType,'const');
    constOut.SimulinkRate=hInSignals(1).SimulinkRate;
    constName=sprintf('%s_const',compName);
    pirelab.getConstComp(hN,constOut,0,constName);
    relopName=sprintf('%s_relop',compName);
    hOutSignal=hN.addSignal(boolType,outSigName);
    pirelab.getRelOpComp(hN,[hInSignals,constOut],hOutSignal,opName,true,relopName);
end
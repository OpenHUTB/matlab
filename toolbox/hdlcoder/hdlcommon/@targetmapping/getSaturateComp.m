
function satComp=getSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,name)


    if(targetcodegen.targetCodeGenerationUtils.isNFPMode())

        satComp=targetmapping.getNFPSaturateComp(hN,hInSignals,hOutSignals,lowerLimit,upperLimit,name);
        return;
    end

    baseType=hInSignals(1).Type;
    boolType=pir_boolean_t;

    upperLimitConstOut=hN.addSignal(baseType,'upperLimitConst');
    upperLimitConstOut.SimulinkRate=hInSignals(1).SimulinkRate;

    upperConstName=sprintf('%s_upper',name);
    pirelab.getConstComp(hN,upperLimitConstOut,upperLimit,upperConstName);
    lessThanEqualOut=hN.addSignal(boolType,'upperLimitOut');
    lessThanEqualOut.SimulinkRate=hInSignals(1).SimulinkRate;

    upperRelopName=sprintf('%s_relop_upper',name);
    pirelab.getRelOpComp(hN,[hInSignals,upperLimitConstOut],lessThanEqualOut,'<=',true,upperRelopName);

    lowerLimitConstOut=hN.addSignal(baseType,'lowerLimitConst');
    lowerLimitConstOut.SimulinkRate=hInSignals(1).SimulinkRate;

    lowerConstName=sprintf('%s_lower',name);
    pirelab.getConstComp(hN,lowerLimitConstOut,lowerLimit,lowerConstName);
    greaterThanEqualOut=hN.addSignal(boolType,'lowerLimitOut');
    greaterThanEqualOut.SimulinkRate=hInSignals(1).SimulinkRate;

    lowerRelopName=sprintf('%s_relop_lower',name);
    pirelab.getRelOpComp(hN,[hInSignals,lowerLimitConstOut],greaterThanEqualOut,'>=',true,lowerRelopName);
    ufix2Type=pir_ufixpt_t(2,0);
    concatOutSignal=hN.addSignal(ufix2Type,'concatOutSignal');
    concatOutSignal.SimulinkRate=hInSignals(1).SimulinkRate;
    concatInputs=[lessThanEqualOut,greaterThanEqualOut];
    pirelab.getBitConcatComp(hN,concatInputs,concatOutSignal,'concat');
    constOut=hN.addSignal(baseType,'const');
    constOut.SimulinkRate=hInSignals(1).SimulinkRate;
    constName=sprintf('%s_const',name);
    pirelab.getConstComp(hN,constOut,0,constName);











    switchInputs=[concatOutSignal,constOut,upperLimitConstOut,lowerLimitConstOut,hInSignals];
    satComp=pirelab.getMultiPortSwitchComp(hN,switchInputs,hOutSignals,1,1);
end


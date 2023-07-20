
function satComp=getSaturationDynamicComp(hN,hInSignals,hOutSignals,name)




    if(targetcodegen.targetCodeGenerationUtils.isNFPMode())

        satComp=targetmapping.getNFPSaturationDynamicComp(hN,hInSignals,hOutSignals,name);
        return;
    end

    upperlim=hInSignals(1);
    u=hInSignals(2);
    lowerlim=hInSignals(3);
    inType=hInSignals(2).Type;
    boolType=pir_boolean_t;
    if inType.isArrayType
        boolType=pirelab.createPirArrayType(boolType,inType.Dimensions);
    end


    lessThanEqualOut=hN.addSignal(boolType,'upperLimitOut');
    lessThanEqualOut.SimulinkRate=hInSignals(1).SimulinkRate;
    upperRelopName=sprintf('%s_relop_upper',name);
    pirelab.getRelOpComp(hN,[u,upperlim],lessThanEqualOut,'<=',true,upperRelopName);


    greaterThanEqualOut=hN.addSignal(boolType,'lowerLimitOut');
    greaterThanEqualOut.SimulinkRate=hInSignals(3).SimulinkRate;
    lowerRelopName=sprintf('%s_relop_lower',name);
    pirelab.getRelOpComp(hN,[u,lowerlim],greaterThanEqualOut,'>=',true,lowerRelopName);

    ufix2Type=pir_ufixpt_t(2,0);
    if inType.isArrayType
        ufix2Type=pirelab.createPirArrayType(ufix2Type,inType.Dimensions);
    end
    concatOutSignal=hN.addSignal(ufix2Type,'concatOutSignal');
    concatOutSignal.SimulinkRate=hInSignals(1).SimulinkRate;
    concatInputs=[lessThanEqualOut,greaterThanEqualOut];

    pirelab.getBitConcatComp(hN,concatInputs,concatOutSignal,'concat');

    switchInputs=[concatOutSignal,lowerlim,upperlim,lowerlim,u];
    satComp=pirelab.getMultiPortSwitchComp(hN,switchInputs,hOutSignals,1,1);
end


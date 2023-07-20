function hNewC=elaborate(this,hN,hC)


    [compareStr,compareVal,roundMode,overflowMode]=this.getBlockInfo(hC);

    dataInputs=[hC.SLInputSignals(1),hC.SLInputSignals(3)];
    select=hC.SLInputSignals(2);

    [~,selType]=pirelab.getVectorTypeInfo(select);
    fullSelType=select.Type;
    sw=get_param(hC.SimulinkHandle,'object');
    criteriaValues=sw.getPropAllowedValues('Criteria');
    isFloatingPointMode=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode;
    if selType.isBooleanType




        if((strcmp(compareStr,criteriaValues{1})&&(compareVal~=1))||...
            (strcmp(compareStr,criteriaValues{2})&&(compareVal~=0))||...
            (strcmp(compareStr,criteriaValues{3})&&(compareVal~=0)))
            compareStr=criteriaValues{3};
            compareVal=0;
        end

        if isFloatingPointMode&&strcmp(compareStr,criteriaValues{2})&&...
            compareVal==0
            compareStr=criteriaValues{3};
        end
    end

    if strcmp(compareStr,criteriaValues{1})
        compareStr='>=';
    elseif strcmp(compareStr,criteriaValues{2})
        compareStr='>';
    else
        compareStr='~=';
        compareVal=0;
    end

    if selType.isFloatType&&isFloatingPointMode
        if strcmp(compareStr,'>=')||strcmp(compareStr,'>')
            nfpOptions=getNFPBlockInfo(this);


            constSig=hN.addSignal(fullSelType,[hC.Name,'_threshold']);
            constSig.SimulinkRate=hC.PirInputSignals(2).SimulinkRate;
            compareValComp=pirelab.getConstComp(hN,constSig,compareVal);


            if fullSelType.isMatrix

                selectBooleanType=pirelab.createPirArrayType(hdlcoder.tp_boolean,fullSelType.getDimensions);
            else

                selectBooleanType=pirelab.getPirVectorType(hdlcoder.tp_boolean,fullSelType.getDimensions);
            end
            selectBoolean=hN.addSignal(selectBooleanType,[hC.Name,'_control']);
            selectBoolean.SimulinkRate=hC.PirInputSignals(2).SimulinkRate;
            pirelab.getRelOpComp(hN,[select,compareValComp.PirOutputSignals],selectBoolean,compareStr,...
            false,[hC.Name,'_relop'],'',-1,nfpOptions);

            select=selectBoolean;
            compareStr='~=';
            compareVal=0;
        else

            selectAbs=hN.addSignal(fullSelType,[hC.Name,'_control_abs']);
            selectAbs.SimulinkRate=hC.PirInputSignals(2).SimulinkRate;
            pirelab.getAbsComp(hN,select,selectAbs);

            select=selectAbs;
        end
    end

    hNewC=pirelab.getSwitchComp(hN,dataInputs,hC.SLOutputSignals,select,...
    hC.Name,compareStr,compareVal,roundMode,overflowMode);

end



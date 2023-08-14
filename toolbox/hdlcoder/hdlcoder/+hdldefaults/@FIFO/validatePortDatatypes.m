function v=validatePortDatatypes(~,hC)



    v=hdlvalidatestruct;


    dIn=hC.SLInputSignals(1);

    if dIn.type.isArrayType

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:FIFOdimensionunsupported'));
    end


    dinLeafType=getPirSignalLeafType(dIn.Type);

    if dinLeafType.isFloatType()&&~targetcodegen.targetCodeGenerationUtils.isNFPMode()

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:FIFOFloatUnsupported'));
    end








    ctrlInLeafTypes=[getPirSignalLeafType(hC.SLInputSignals(2).Type),getPirSignalLeafType(hC.SLInputSignals(3).Type)];
    ctrlInTypesValid=arrayfun(@(ii)ctrlInLeafTypes(ii).is1BitType,1:2);
    if~all(ctrlInTypesValid)

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:FIFOrequestboolean'));
    end






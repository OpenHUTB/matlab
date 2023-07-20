function v=validateBlock(this,hC)%#ok<INUSD> 



    v=hdlvalidatestruct;

    hCRn=hC.ReferenceNetwork;
    din=hCRn.PirInputSignals;
    inputType=din.Type;
    isInputFloat=inputType.BaseType.isFloatType();


    if isInputFloat
        v(end+1)=hdlvalidatestruct(1,message('mcb:blocks:HdlSpeedMeasurmentInputDataType'));
    end







function fixdtString=getFixdtString(hDialog,dtTag,dtaItems)


    scalingModeTag=[dtTag,'|UDTScalingModeRadio'];
    signModeTag=[dtTag,'|UDTSignRadio'];
    wordLengthTag=[dtTag,'|UDTWordLengthEdit'];

    if~hDialog.isWidgetValid(scalingModeTag)





        switch dtaItems.scalingModes{1}
        case 'UDTBinaryPointMode'
            fixdtString='fixdt(1,16,0)';
        case 'UDTSlopeBiasMode'
            fixdtString='fixdt(1,16,2^0,0)';
        case{'UDTBestPrecisionMode','UDTIntegerMode'}
            fixdtString='fixdt(1,16)';
        end
        return;
    end

    scalingMode=hDialog.getWidgetValue(scalingModeTag);

    switch dtaItems.scalingModes{scalingMode+1}
    case 'UDTBinaryPointMode'
        signMode=hDialog.getWidgetValue(signModeTag);
        switch dtaItems.signModes{signMode+1}
        case 'UDTInheritSign'
            sign='[]';
        case 'UDTSignedSign'
            sign='1';
        case 'UDTUnsignedSign'
            sign='0';
        end
        wordLength=hDialog.getWidgetValue(wordLengthTag);
        fractionLengthTag=[dtTag,'|UDTFractionLengthEdit'];
        fractionLength=hDialog.getWidgetValue(fractionLengthTag);
        fixdtString=Simulink.DataTypePrmWidget.fixdtFieldsToString(sign,wordLength,fractionLength);
    case 'UDTSlopeBiasMode'
        signMode=hDialog.getWidgetValue(signModeTag);
        switch dtaItems.signModes{signMode+1}
        case 'UDTInheritSign'
            sign='[]';
        case 'UDTSignedSign'
            sign='1';
        case 'UDTUnsignedSign'
            sign='0';
        end
        wordLength=hDialog.getWidgetValue(wordLengthTag);
        slopeTag=[dtTag,'|UDTSlopeEdit'];
        biasTag=[dtTag,'|UDTBiasEdit'];
        slope=hDialog.getWidgetValue(slopeTag);
        bias=hDialog.getWidgetValue(biasTag);
        fixdtString=Simulink.DataTypePrmWidget.fixdtFieldsToString(sign,wordLength,slope,bias);
    case 'UDTBestPrecisionMode'
        signMode=hDialog.getWidgetValue(signModeTag);
        switch dtaItems.signModes{signMode+1}
        case 'UDTInheritSign'
            sign='[]';
        case 'UDTSignedSign'
            sign='1';
        case 'UDTUnsignedSign'
            sign='0';
        end
        wordLength=hDialog.getWidgetValue(wordLengthTag);
        fixdtString=Simulink.DataTypePrmWidget.fixdtFieldsToString(sign,wordLength);
    case 'UDTIntegerMode'
        signMode=hDialog.getWidgetValue(signModeTag);
        switch dtaItems.signModes{signMode+1}
        case 'UDTInheritSign'
            sign='[]';
        case 'UDTSignedSign'
            sign='1';
        case 'UDTUnsignedSign'
            sign='0';
        end
        wordLength=hDialog.getWidgetValue(wordLengthTag);
        fractionLength='0';
        fixdtString=Simulink.DataTypePrmWidget.fixdtFieldsToString(sign,wordLength,fractionLength);
    otherwise
        assert(true,'Unrecognized scaling mode.');
    end





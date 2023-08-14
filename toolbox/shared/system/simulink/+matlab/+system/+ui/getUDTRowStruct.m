function dtRow=getUDTRowStruct(rule,prop)




    dtSet=prop.DataTypeSet;
    dtRow=struct('name',prop.Description);
    dtRow.prefix=prop.Prefix;
    dtRow.hasDesignMin=dtSet.HasDesignMinimum;
    dtRow.hasDesignMax=dtSet.HasDesignMaximum;


    dtRow.inheritInternalRule=0;
    dtRow.inheritBackProp=0;
    dtRow.inheritSameWLAsInput=0;
    dtRow.inheritInput=0;
    dtRow.inheritFirstInput=0;
    dtRow.inheritSecondInput=0;
    dtRow.inheritProdOutput=0;
    dtRow.inheritAccumulator=0;
    dtValues=dtSet.DataTypeRules;
    for dtInd=1:numel(dtValues)
        switch matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(dtValues{dtInd})
        case 'Inherit: Inherit via internal rule'
            dtRow.inheritInternalRule=1;
        case 'Inherit: Inherit via back propagation'
            dtRow.inheritBackProp=1;
        case 'Inherit: Same word length as input'
            dtRow.inheritSameWLAsInput=1;
        case 'Inherit: Same as input'
            dtRow.inheritInput=1;
        case 'Inherit: Same as first input'
            dtRow.inheritFirstInput=1;
        case 'Inherit: Same as second input'
            dtRow.inheritSecondInput=1;
        case 'Inherit: Same as product output'
            dtRow.inheritProdOutput=1;
        case 'Inherit: Same as accumulator'
            dtRow.inheritAccumulator=1;
        end
    end


    dtRow.customInhRuleStrs={};
    dtRow.builtinTypes={};


    dtRow.defaultUDTStrValue=matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(rule);

    if~isempty(dtSet.CustomDataType)

        allowedSignedness=dtSet.CustomDataType.Signedness;
        dtRow.signedSignedness=double(ismember('Signed',allowedSignedness));
        dtRow.unsignedSignedness=double(ismember('Unsigned',allowedSignedness));
        dtRow.autoSignedness=double(ismember('Auto',allowedSignedness));


        allowedScaling=dtSet.CustomDataType.Scaling;
        dtRow.binaryPointScaling=double(ismember('BinaryPoint',allowedScaling));
        dtRow.bestPrecisionMode=double(ismember('Unspecified',allowedScaling));
    else
        dtRow.signedSignedness=0;
        dtRow.unsignedSignedness=0;
        dtRow.autoSignedness=0;
        dtRow.binaryPointScaling=0;
        dtRow.bestPrecisionMode=0;
    end


    if~isempty(dtSet.ValuePropertyName)
        dtRow.hasValBestPrecFLMode=1;
        dtRow.valBestPrecFLMaskPrm=dtSet.ValuePropertyName;
    else
        dtRow.hasValBestPrecFLMode=0;
        dtRow.valBestPrecFLMaskPrm='';
    end
end
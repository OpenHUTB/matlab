function type=getUDTMaskType(sysobj,property,pNames)




    thisDTRowInfo=matlab.system.ui.getUDTRowStruct(sysobj.(property.Name),property);
    type=getSPCDTInfoMaskVarStr(thisDTRowInfo,pNames);
end

function dtInfStlStr=getSPCDTInfoMaskVarStr(thisDTRowInfo,pNames)

    uniDTPreStr=getUDTPrfxForStyleStr(thisDTRowInfo,pNames);
    uniDTInhStr=getUDTInheritStyleStr(thisDTRowInfo);
    uniDTSgnStr=getUDTSgdnessStyleStr(thisDTRowInfo);
    uniDTSclStr=getUDTScalingStyleStr(thisDTRowInfo);
    dtInfStlStr=strcat(uniDTPreStr,uniDTInhStr,uniDTSclStr,uniDTSgnStr,')');
end

function uniDTPreStr=getUDTPrfxForStyleStr(thisDTRowInfo,pNames)



    dtPrmInd=num2str(find(strcmp(pNames,[thisDTRowInfo.prefix,'DataTypeStr'])));
    uniDTPreStr=['unidt({a=',dtPrmInd,'|'];

    if isfield(thisDTRowInfo,'hasDesignMin')&&(thisDTRowInfo.hasDesignMin)
        dtMinPrmInd=num2str(find(strcmp(pNames,[thisDTRowInfo.prefix,'Min'])));
        uniDTPreStr=[uniDTPreStr,dtMinPrmInd];
    end
    uniDTPreStr=[uniDTPreStr,'|'];
    if isfield(thisDTRowInfo,'hasDesignMax')&&(thisDTRowInfo.hasDesignMax)
        dtMaxPrmInd=num2str(find(strcmp(pNames,[thisDTRowInfo.prefix,'Max'])));
        uniDTPreStr=[uniDTPreStr,dtMaxPrmInd];
    end
    uniDTPreStr=[uniDTPreStr,'|'];

    if isfield(thisDTRowInfo,'hasValBestPrecFLMode')&&...
        (thisDTRowInfo.hasValBestPrecFLMode)&&...
        isfield(thisDTRowInfo,'valBestPrecFLMaskPrm')&&...
        (~isempty(thisDTRowInfo.valBestPrecFLMaskPrm))
        uniDTPreStr=[uniDTPreStr,num2str(find(strcmp(pNames,thisDTRowInfo.valBestPrecFLMaskPrm)))];
    end
    uniDTPreStr=[uniDTPreStr,'}'];
end

function uniDTInhStr=getUDTInheritStyleStr(thisDTRowInfo)

    hasDTInheritRules=thisDTRowInfo.inheritInternalRule||...
    thisDTRowInfo.inheritSameWLAsInput||...
    thisDTRowInfo.inheritInput||...
    thisDTRowInfo.inheritFirstInput||...
    thisDTRowInfo.inheritSecondInput||...
    thisDTRowInfo.inheritProdOutput||...
    thisDTRowInfo.inheritAccumulator;

    if hasDTInheritRules
        uniDTInhStr='{i=';

        if thisDTRowInfo.inheritInternalRule
            oldDTInhStr=uniDTInhStr;
            uniDTInhStr=strcat(oldDTInhStr,'Inherit: Inherit via internal rule|');
        end
        if thisDTRowInfo.inheritSameWLAsInput
            oldDTInhStr=uniDTInhStr;
            uniDTInhStr=strcat(oldDTInhStr,'Inherit: Same word length as input|');
        end
        if thisDTRowInfo.inheritInput
            oldDTInhStr=uniDTInhStr;
            uniDTInhStr=strcat(oldDTInhStr,'Inherit: Same as input|');
        end
        if thisDTRowInfo.inheritFirstInput
            oldDTInhStr=uniDTInhStr;
            uniDTInhStr=strcat(oldDTInhStr,'Inherit: Same as first input|');
        end
        if thisDTRowInfo.inheritSecondInput
            oldDTInhStr=uniDTInhStr;
            uniDTInhStr=strcat(oldDTInhStr,'Inherit: Same as second input|');
        end
        if thisDTRowInfo.inheritProdOutput
            oldDTInhStr=uniDTInhStr;
            uniDTInhStr=strcat(oldDTInhStr,'Inherit: Same as product output|');
        end
        if thisDTRowInfo.inheritAccumulator
            oldDTInhStr=uniDTInhStr;
            uniDTInhStr=strcat(oldDTInhStr,'Inherit: Same as accumulator|');
        end

        oldDTInhStr=uniDTInhStr;
        uniDTInhStr=strcat(oldDTInhStr(1:end-1),'}');
    else
        uniDTInhStr='';
    end
end

function uniDTSgnStr=getUDTSgdnessStyleStr(thisDTRowInfo)

    allowsSigned=logical(thisDTRowInfo.signedSignedness);
    allowsUnsigned=logical(thisDTRowInfo.unsignedSignedness);
    allowsAuto=logical(thisDTRowInfo.autoSignedness);
    if allowsSigned||allowsUnsigned||allowsAuto
        uniDTSgnStr='{g=';




        if allowsAuto
            uniDTSgnStr=strcat(uniDTSgnStr,'UDTInheritSign|');
        end
        if allowsSigned
            uniDTSgnStr=strcat(uniDTSgnStr,'UDTSignedSign|');
        end
        if allowsUnsigned
            uniDTSgnStr=strcat(uniDTSgnStr,'UDTUnsignedSign|');
        end
        uniDTSgnStr=uniDTSgnStr(1:end-1);
        uniDTSgnStr=strcat(uniDTSgnStr,'}');
    else
        uniDTSgnStr='{g=UDTSignedSign}';
    end
end

function uniDTSclStr=getUDTScalingStyleStr(thisDTRowInfo)


    if thisDTRowInfo.bestPrecisionMode&&thisDTRowInfo.binaryPointScaling
        uniDTSclStr='{s=UDTBinaryPointMode|UDTBestPrecisionMode}';
    elseif thisDTRowInfo.bestPrecisionMode
        uniDTSclStr='{s=UDTBestPrecisionMode}';
    elseif thisDTRowInfo.binaryPointScaling
        uniDTSclStr='{s=UDTBinaryPointMode}';
    else
        uniDTSclStr='';
    end
end



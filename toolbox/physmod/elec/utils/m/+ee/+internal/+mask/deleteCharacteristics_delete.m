function deleteCharacteristics_delete(modelName)



    ds=ee.internal.mask.getSimscapeBlockDatasetFromModel(modelName);
    blockName=[modelName,'/ListOfCharacteristics'];

    charIndex=value(ee.internal.mask.getParamWithUnit(blockName,'characteristicIndex'),'1');
    curvIndex=value(ee.internal.mask.getParamWithUnit(blockName,'curveIndex'),'1');
    if isempty(charIndex)||~isnumeric(charIndex)||any(charIndex<=0)||any(mod(charIndex,1))
        pm_error('physmod:ee:library:NotNumeric',getString(message('physmod:ee:library:comments:utils:mask:deleteCharacteristics_delete:error_CharacteristicIndex')));
    end
    if isempty(curvIndex)||~isnumeric(curvIndex)||any(curvIndex<=0)||any(mod(curvIndex,1))
        pm_error('physmod:ee:library:NotNumeric',getString(message('physmod:ee:library:comments:utils:mask:deleteCharacteristics_delete:error_CurveIndex')));
    end

    charIndex=unique(charIndex(:));
    curvIndex=unique(curvIndex(:));
    maxChar=length(ds.characteristicData);
    for ii=length(charIndex):-1:1
        if charIndex(ii)<=maxChar
            maxCurv=length(ds.characteristicData(charIndex(ii)).curves);
            for jj=length(curvIndex):-1:1
                if curvIndex(jj)<=maxCurv
                    ds.characteristicData(charIndex(ii)).deleteCurve(curvIndex(jj));
                end
            end
            if isempty(ds.characteristicData(charIndex(ii)).curves)
                ds.deleteCharacteristic(charIndex(ii));
            end
        end
    end
end
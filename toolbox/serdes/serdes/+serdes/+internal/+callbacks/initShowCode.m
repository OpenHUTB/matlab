



function initShowCode(block)

    maskObj=Simulink.Mask.get(block);
    maskNames={maskObj.Parameters.Name};
    if any(contains(maskNames,'ExternalInit'))
        initMaskExternalInit=maskObj.Parameters(strcmp(maskNames,'ExternalInit')).Value;
        isExternalInit=strcmp(initMaskExternalInit,'on');
    else
        isExternalInit=false;
    end

    if~isExternalInit
        pathToMLFunc=[block,'/Initialize Function/MATLAB Function'];
        open_system(pathToMLFunc);
    else
        txOrRxBlockName=extractAfter(block,[bdroot(block),'/']);
        if contains(txOrRxBlockName,'/')
            txOrRxBlockName=extractBefore(txOrRxBlockName,'/');
        end
        fileToEdit=[lower(txOrRxBlockName),'Init.m'];
        if isfile(fileToEdit)
            edit(fileToEdit)
        else
            error(message('serdes:utilities:ExternalInitFilesMissing'));
        end
    end
end
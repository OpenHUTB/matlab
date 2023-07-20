function checksum=computeBlockParameterChecksum(this,block)








    maskParam=this.blockGetParameterModes(block);

    maskNames=block.MaskNames;
    maskValues=block.MaskValues;
    if~isempty(maskParam)

        nonEditableParamsInRestrictedMode={maskParam(strcmp(PARAM_AUTHORING,{maskParam.editingMode})).maskName};

        nonEditableParamsInRestrictedModeIdx=ismember(maskNames,nonEditableParamsInRestrictedMode);

        nonEditableParamsInRestrictedModeValues=maskValues(nonEditableParamsInRestrictedModeIdx);

        nonEditableParamsInRestrictedModeNames=maskNames(nonEditableParamsInRestrictedModeIdx);



        [dummy,sortIdx]=sort(nonEditableParamsInRestrictedModeNames);
        checksum=pm_hash('crc',nonEditableParamsInRestrictedModeValues(sortIdx));

    else




        checksum=pm_hash('crc',[]);
    end




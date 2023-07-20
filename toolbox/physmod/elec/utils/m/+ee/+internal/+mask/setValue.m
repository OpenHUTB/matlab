function setValue(blockName,parameterName,parameterValue,parameterUnit)










    if isnumeric(blockName)&&ishandle(blockName)
        blockName=[get_param(blockName,'Parent'),'/',get_param(blockName,'Name')];
    end

    try
        maskUnit=get_param(blockName,[parameterName,'_unit']);
    catch
        pm_error('physmod:ee:library:MaskParameterNotExist',blockName,parameterName);
    end

    if~ischar(parameterValue)&&~(isstring(parameterValue)&&isscalar(parameterValue))
        pm_error('physmod:ee:library:ParameterValueString','parameterValue');
    end
    parameterValue=char(parameterValue);

    if~pm_commensurate(parameterUnit,maskUnit)
        maskPrompt=simscape.compiler.sli.internal.parameterpromptfromblock(...
        parameterName,blockName);
        pm_error('physmod:ee:library:MaskParameterUnitNotCommensurate',blockName,maskPrompt,parameterName,parameterUnit,maskUnit);
    end

    set_param(blockName,parameterName,parameterValue);
    set_param(blockName,[parameterName,'_unit'],parameterUnit);

end

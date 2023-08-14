function parameterValue=getValue(blockName,parameterName,requiredUnit)










    if isnumeric(blockName)&&ishandle(blockName)
        blockName=[get_param(blockName,'Parent'),'/',get_param(blockName,'Name')];
    end



    Simulink.Block.eval(blockName);


    maskWSVariables=get_param(blockName,'MaskWSVariables');

    variableIdx=strcmp(parameterName,{maskWSVariables(:).Name});

    if any(variableIdx)
        maskValue=maskWSVariables(variableIdx).Value;
    else
        pm_error('physmod:ee:library:MaskParameterNotExist',blockName,parameterName);
    end

    if isempty(maskValue)
        maskPrompt=simscape.compiler.sli.internal.parameterpromptfromblock(parameterName,blockName);
        pm_error('physmod:ee:library:MaskParameterNotEvaluated',blockName,maskPrompt,parameterName);
    end

    maskUnit=get_param(blockName,[parameterName,'_unit']);

    if~pm_commensurate(requiredUnit,maskUnit)
        maskPrompt=simscape.compiler.sli.internal.parameterpromptfromblock(parameterName,blockName);
        pm_error('physmod:ee:library:MaskParameterUnitNotCommensurate',blockName,maskPrompt,parameterName,requiredUnit,maskUnit);
    end

    valueWithUnit=simscape.Value(maskValue,maskUnit);
    parameterValue=valueWithUnit.value(requiredUnit);

end
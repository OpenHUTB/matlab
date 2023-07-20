function blockData=translateComponentDataToBlockData(componentData)%#ok<*AGROW>










    persistent variableSuffixes rtconfigSuffix
    if isempty(variableSuffixes)

        vs=nesl_private('nesl_variabletargetsuffixes');
        variableSuffixes=vs();


        nesl_parametersuffixes=nesl_private('nesl_parametersuffixes');
        [~,~,rtconfigSuffix]=nesl_parametersuffixes();

    end

    blockData(1).Name='SourceFile';
    blockData(1).Value=componentData.getClass();

    variableData=componentData.getVariables();
    for idx=1:numel(variableData)
        blockData(end+1).Name=[variableData(idx).id,variableSuffixes.varSuffix];
        blockData(end).Value=variableData(idx).value;

        blockData(end+1).Name=[variableData(idx).id,variableSuffixes.unitSuffix];
        blockData(end).Value=variableData(idx).unit;

        blockData(end+1).Name=[variableData(idx).id,variableSuffixes.prioritySuffix];
        blockData(end).Value=variableData(idx).priority;

        blockData(end+1).Name=[variableData(idx).id,variableSuffixes.specifySuffix];
        blockData(end).Value=variableData(idx).specify;
    end

    parameterData=componentData.getParameters();
    for idx=1:numel(parameterData)
        blockData(end+1).Name=[parameterData(idx).id,variableSuffixes.varSuffix];
        blockData(end).Value=parameterData(idx).value;

        blockData(end+1).Name=[parameterData(idx).id,variableSuffixes.unitSuffix];
        blockData(end).Value=parameterData(idx).unit;

        blockData(end+1).Name=[parameterData(idx).id,rtconfigSuffix];
        blockData(end).Value=parameterData(idx).rtconfig;
    end

end
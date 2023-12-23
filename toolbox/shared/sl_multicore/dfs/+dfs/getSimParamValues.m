function paramValuesStr=getSimParamValues(modelName)

    paramValuesStr='';
    names={'SimCompilerOptimization','SimCtrlC',...
    'IntegerOverflowMsg','IntegerSaturationMsg'};


    for i=1:numel(names)
        paramValuesStr=[paramValuesStr,get_param(modelName,names{i})];
    end

end

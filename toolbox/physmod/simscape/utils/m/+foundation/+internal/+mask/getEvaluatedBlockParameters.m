function params=getEvaluatedBlockParameters(blk,includeDefaults)


















    excludeSuffix={
'_conf'
'_nominal_specify'
'_nominal_unit'
'_nominal_value'
'_priority'
'_specify'
    '_unit'};

    if nargin<2
        includeDefaults=true;
    end



    Simulink.Block.eval(blk)


    maskObj=pm.sli.internal.rootMask(blk);
    pm_assert(~isempty(maskObj),'Must be a linked Simscape block.');



    maskWS=get_param(blk,'MaskWSVariables');
    maskWS=maskWS(~endsWith({maskWS.Name},excludeSuffix));


    names={};
    values={};
    units={};
    prompts={};
    for idx=1:numel(maskWS)
        maybeParam=maskObj.getParameter(maskWS(idx).Name);
        if~isempty(maybeParam)&&strcmp(maybeParam.Evaluate,'on')
            names{end+1,1}=maybeParam.Name;%#ok<AGROW>
            values{end+1,1}=lGetValue(maskWS(idx));%#ok<AGROW>
            units{end+1,1}=lGetUnit(maskObj,maybeParam.Name);%#ok<AGROW>
            prompts{end+1,1}=maybeParam.Prompt;%#ok<AGROW>
        end
    end


    params=table(values,units,prompts,'RowNames',names,...
    'VariableNames',{'Value','Unit','Prompt'});


    if includeDefaults&&simscape.engine.sli.internal.issimscapeblock(blk)
        params=lMergeDefaults(params,blk);
    end

end

function params=lMergeDefaults(maskValues,blk)
    params=foundation.internal.mask.getEvaluatedParameterDefaults(blk);
    params=sortrows(params,'RowNames');
    maskNames=maskValues.Properties.RowNames;
    for idx=1:numel(maskNames)
        params(maskNames{idx},:)=maskValues(maskNames{idx},:);
    end
end

function value=lGetValue(maskWSParam)


    maskWSValue=maskWSParam.Value;
    if isa(maskWSParam.Value,'Simulink.Parameter')
        value=maskWSValue.Value;
    else
        value=maskWSValue;
    end
end

function unit=lGetUnit(maskObj,baseName)


    unit='';
    maybeParam=maskObj.getParameter([baseName,'_unit']);
    if~isempty(maybeParam)
        unit=maybeParam.Value;
    end
end
function addBlock(modelName,refBlock,subsysPath,blockName,position,params)




    if isempty(refBlock)
        return;
    end
    paramsToChange=[];
    if~isempty(subsysPath)
        fullPath=[modelName,'/',strrep(subsysPath,'.','/'),'/',blockName];
    else
        fullPath=[modelName,'/',blockName];
    end
    if strcmpi(refBlock,'subsystem')
        b=add_block('built-in/Subsystem',fullPath,'Position',[15,15,55,55]);

        paramsToChange(end+1).name='Mask';
        paramsToChange(end).value='on';
    elseif strcmpi(refBlock,'pmioport')
        b=add_block('built-in/PMIOPort',fullPath);
        paramsToChange=params;
    else
        b=add_block(refBlock,fullPath);
        maskParams=get_param(b,'MaskNames');
        compParams={params.name};
        idx=ismember(compParams,maskParams);
        if any(idx)
            paramsToChange=params(idx);
        end
        paramsToChange(end+1).name='Orientation';
        paramsToChange(end).value='right';

    end

    paramsToChange(end+1).name='Position';
    paramsToChange(end).value=position;
    blockParams=struct2cell(paramsToChange);
    set_param(b,blockParams{:});
end

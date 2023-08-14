function params=getEvaluatedParameterDefaults(blk)






    i=physmod.schema.internal.blockComponentSchema(blk).info();


    params=[lGetParams(i.Members.Parameters);lGetVars(i.Members.Variables)];

end

function t=lGetParams(params)

    values=cell(size(params));
    units=cell(size(params));
    prompts={params.Label}';
    names={params.ID}';


    for idx=1:numel(params)
        [values{idx},units{idx}]=lValue(params(idx).Default);
    end


    t=lMakeTable(names,values,units,prompts);
end

function t=lGetVars(vars)

    values=cell(size(vars));
    units=cell(size(vars));
    prompts={vars.Label}';
    names={vars.ID}';


    for idx=1:numel(vars)
        [values{idx},units{idx}]=lValue(vars(idx).Default.Value);
    end


    t=lMakeTable(names,values,units,prompts);
end

function[val,unit]=lValue(def)

    unit=def.Unit;
    val=eval(def.Value);
end

function t=lMakeTable(names,values,units,prompts)

    t=table(values,units,prompts,'RowNames',names,...
    'VariableNames',{'Value','Unit','Prompt'});
end
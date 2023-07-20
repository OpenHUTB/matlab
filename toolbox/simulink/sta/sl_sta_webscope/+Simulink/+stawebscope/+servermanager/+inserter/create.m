function obj=create(Item,InputData)




    if strcmp(Item.Type,'FunctionCall')
        obj=Simulink.stawebscope.servermanager.inserter.FcnCallInserter(Item,InputData);
    elseif isfield(Item,'isEnum')&&Item.isEnum
        obj=Simulink.stawebscope.servermanager.inserter.EnumInserter(Item,InputData);
    elseif isstruct(InputData{1}{2})
        obj=Simulink.stawebscope.servermanager.inserter.FixedPointInserter(Item,InputData);
    elseif any(strcmp(Item.DataType,{'logical','boolean'}))
        obj=Simulink.stawebscope.servermanager.inserter.LogicalInserter(Item,InputData);
    elseif Item.isString||strcmp(Item.DataType,'string')
        obj=Simulink.stawebscope.servermanager.inserter.StringInserter(Item,InputData);
    else
        obj=Simulink.stawebscope.servermanager.inserter.Inserter(Item,InputData);
    end
end


function applyParameterValue(Blk,ParameterName,Value)




    if~ishandle(Blk)
        validateattributes(Blk,{'char'},{'nonempty'},'','Block');
    end
    validateattributes(ParameterName,{'char'},{'nonempty'},'','parmeter name');
    validateattributes(Value,{'char'},{'nonempty'},'','Value');

    currVal=get_param(Blk,ParameterName);
    if~isequal(currVal,Value)
        set_param(Blk,ParameterName,Value);
    end

end


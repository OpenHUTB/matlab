

function result=isBindModeEnabled(modelHandle)
    modelObj=get_param(modelHandle,'Object');
    result=BindMode.BindMode.isEnabled(modelObj);
end
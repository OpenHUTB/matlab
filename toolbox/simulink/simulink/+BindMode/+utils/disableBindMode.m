

function disableBindMode(modelHandle)
    modelObj=get_param(modelHandle,'Object');
    BindMode.BindMode.disableBindMode(modelObj);
end
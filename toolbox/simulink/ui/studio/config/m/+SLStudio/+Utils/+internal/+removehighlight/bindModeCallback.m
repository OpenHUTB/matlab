

function bindModeCallback(bdHandle)
    mdlObj=get_param(bdHandle,'Object');
    BindMode.BindMode.cleanUpBindMode(mdlObj);
end
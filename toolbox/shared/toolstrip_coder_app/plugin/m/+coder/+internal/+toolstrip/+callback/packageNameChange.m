function packageNameChange(cbinfo)
    mdlH=cbinfo.model.handle;
    set_param(mdlH,'PackageName',cbinfo.EventData);
end
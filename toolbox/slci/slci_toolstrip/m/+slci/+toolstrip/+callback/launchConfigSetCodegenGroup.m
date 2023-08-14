


function launchConfigSetCodegenGroup(cbinfo,~)

    mdl=cbinfo.model.Handle;
    cs=getActiveConfigSet(mdl);

    configset.showParameterGroup(cs,{'CodeGeneration'})
end
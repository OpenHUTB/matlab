


function launchConfigSet(cbinfo,~)

    mdl=cbinfo.model.Handle;
    cs=getActiveConfigSet(mdl);

    cs.view;
end
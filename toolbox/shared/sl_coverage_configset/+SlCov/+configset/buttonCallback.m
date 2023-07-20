function updateDeps=buttonCallback(cs,msg)


    updateDeps=false;

    if isa(cs,'SlCovCC.ConfigComp')
        slcovcc=cs;
    else
        slcovcc=cs.getComponent('Simulink Coverage');
    end

    switch(msg.name)
    case 'SelectModels'
        SlCov.configset.mdlRefBrowseCallback(slcovcc,msg.dialog);
    case 'SelectSubsystem'
        SlCov.configset.subSysBrowseCallback(slcovcc,msg.dialog);
    end
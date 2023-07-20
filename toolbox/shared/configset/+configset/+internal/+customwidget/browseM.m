function updateDeps=browseM(cs,msg)


    updateDeps=false;
    type={'*.m','*.m'};
    configset.internal.customwidget.browse(cs,msg.name,type);



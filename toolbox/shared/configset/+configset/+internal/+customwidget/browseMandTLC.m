function updateDeps=browseMandTLC(cs,msg)


    updateDeps=false;
    type={'*.m','*.m';'*.tlc','*.tlc'};
    configset.internal.customwidget.browse(cs,msg.name,type);

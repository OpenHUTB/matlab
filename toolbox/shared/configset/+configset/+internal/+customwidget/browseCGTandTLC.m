function updateDeps=browseCGTandTLC(cs,msg)


    updateDeps=false;
    type={'*.cgt','*.cgt';'*.tlc','*.tlc';};
    configset.internal.customwidget.browse(cs,msg.name,type);




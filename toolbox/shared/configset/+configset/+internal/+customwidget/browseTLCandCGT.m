function updateDeps=browseTLCandCGT(cs,msg)


    updateDeps=false;
    type={'*.tlc','*.tlc';'*.cgt','*.cgt'};
    configset.internal.customwidget.browse(cs,msg.name,type);




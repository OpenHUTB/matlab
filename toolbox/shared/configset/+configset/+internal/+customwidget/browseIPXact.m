function updateDeps=browseIPXact(cs,msg)


    updateDeps=false;
    type='*.xml';
    configset.internal.customwidget.browse(cs,msg.name,type,'Select IP-XACT file:');



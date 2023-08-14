function updateDeps=openEmbeddedCoderDictionary(cs,~)




    updateDeps=false;
    file=get_param(cs,'EmbeddedCoderDictionary');
    simulinkcoder.internal.app.ViewSDP(file);

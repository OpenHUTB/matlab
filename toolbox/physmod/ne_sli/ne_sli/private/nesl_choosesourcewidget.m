function showWidget=nesl_choosesourcewidget(hBlock)






    showWidget=simscape.engine.sli.internal.iscomponentblock(hBlock)&&...
    simscape.engine.sli.internal.iscomponentspecified(hBlock);


end

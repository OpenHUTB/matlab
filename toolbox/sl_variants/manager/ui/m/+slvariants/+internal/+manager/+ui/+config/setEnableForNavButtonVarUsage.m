function setEnableForNavButtonVarUsage(modelHandle)




    studio=slvariants.internal.manager.core.getStudio(modelHandle);


    toolStrip=studio.getToolStrip;


    as=toolStrip.getActionService();
    as.refreshAction('navigateLeftChoicesAction');
    as.refreshAction('navigateRightChoicesAction');

end

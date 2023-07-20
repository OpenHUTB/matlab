function refreshToolStripActions(modelName)




    modelHandle=get_param(modelName,'handle');
    studio=slvariants.internal.manager.core.getStudio(modelHandle);

    toolStrip=studio.getToolStrip;

    as=toolStrip.getActionService();
    as.refreshAction('autoGenerateConfigsPushButtonAction');
    as.refreshAction('autoGenConfigAddSelectedConfigsPushButtonAction');
    as.refreshAction('autoGenConfigAddPredicateCheckBoxAction');
end

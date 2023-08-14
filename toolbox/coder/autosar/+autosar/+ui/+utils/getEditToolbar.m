



function editToolbar=getEditToolbar(explorer)
    am=DAStudio.ActionManager;

    addActionObj=am.createAction(explorer,...
    'Text',autosar.ui.metamodel.PackageString.AddStr,...
    'icon',[matlabroot,autosar.ui.metamodel.PackageString.AddIcon]);
    deleteActionObj=am.createAction(explorer,...
    'Text',autosar.ui.metamodel.PackageString.DeleteStr,...
    'icon',[matlabroot,autosar.ui.metamodel.PackageString.DeleteIcon]);

    addActionObj.callback=['autosar.ui.utils.addWizard(',num2str(addActionObj.id),')'];
    schema.prop(addActionObj,'callbackData','mxArray');
    addActionObj.callbackData={explorer};

    deleteActionObj.callback=['autosar.ui.utils.deleteNode(',num2str(deleteActionObj.id),')'];
    schema.prop(deleteActionObj,'callbackData','mxArray');
    deleteActionObj.callbackData={explorer};

    editToolbar=am.createToolBar(explorer);
    editToolbar.addAction(addActionObj);
    editToolbar.addAction(deleteActionObj);
    editToolbar.visible=false;
end



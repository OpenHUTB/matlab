function item=getCurrentItem()




    bdH=get_param(bdroot,'Handle');

    sysArchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);

    edCtrl=sysArchApp.getCurrentEditor;

    selectedElems=edCtrl.getSelection().getSelected();
    if~isempty(selectedElems)
        diagElem=edCtrl.editorModel.findElement(selectedElems(1).uuid);
        mfModel=sysarchApp.getArchitectureViewsManager.getModel;
        item=mfModel.findElement(diagElem.semanticElement);


    end
end

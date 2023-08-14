function createLinkOrImport(actionName,cbinfo)





    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isempty(block)
        if isempty(cbinfo.getSelection)

            modelH=cbinfo.studio.App.getActiveEditor.blockDiagramHandle;
            assert(autosar.composition.Utils.isEmptyBlockDiagram(modelH),...
            '%s is not empty!',getfullname(modelH));
            slSourceH=modelH;
        else




            selection=cbinfo.selection;
            slSourceH=...
            autosar.composition.studio.ActionStateGetter.getValidSelectedBlocksForAction(...
            actionName,selection);
        end
    else
        slSourceH=block.handle;
    end

    switch actionName
    case 'autosarCreateModelAction'
        autosar.composition.studio.CreateAndLink.createModelForComp(slSourceH);
    case 'autosarLinkToModelAction'
        autosar.composition.studio.CreateAndLink.linkCompToModel(slSourceH);
    case 'autosarImportFromARXMLAction'
        autosar.composition.studio.CreateAndLink.importCompFromARXML(slSourceH);
    case 'autosarSaveAsArchitectureModelAction'

        autosar.composition.studio.CreateAndLink.createModelForComp(slSourceH);
    otherwise
        assert(false,'Unexpected option for adding behavior');
    end




function variantTransitionCB(cbinfo,varargin)
    selection=cbinfo.selection;
    if selection.size==1
        backendId=cbinfo.selection.at(1).backendId;
        editor=cbinfo.studio.App.getActiveEditor;

        undoId='Stateflow:studio:ChangeIsVariantUndo';
        editor.createMCommand(undoId,DAStudio.message(undoId),@setIsVariant,{backendId});
    end
end

function setIsVariant(backendId)
    m3iObject=StateflowDI.Util.getDiagramElement(backendId);
    currValue=m3iObject.temporaryObject.isVariant;
    m3iObject.temporaryObject.isVariant=~currValue;
end

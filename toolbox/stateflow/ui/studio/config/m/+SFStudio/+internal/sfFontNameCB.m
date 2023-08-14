



function sfFontNameCB(cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    undoId='simulink_ui:studio:resources:setFontNameUndo';
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setFontName,{cbinfo});
end

function loc_setFontName(cbinfo)
    selection=cbinfo.selection;
    for j=1:selection.size
        obj=selection.at(j);
        if obj.isvalid&&~isa(obj,'StateflowDI.Junction')
            if~strcmp(obj.font.actualFontName,cbinfo.EventData)
                m=M3I.ImmutableModel.cast(obj.modelM3I.getRootDeviant);
                obj=obj.asDeviant(m);
                obj.font.actualFontName=cbinfo.EventData;
            end
        end
    end
end

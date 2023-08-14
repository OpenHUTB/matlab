



function fontNameCB(cbinfo)

    parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);
    handles=unique([parts.blocks,parts.notes,parts.segments]);


    editor=cbinfo.studio.App.getActiveEditor;
    undoId='simulink_ui:studio:resources:setFontNameUndo';
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setFontName,{cbinfo,handles});
end

function loc_setFontName(cbinfo,handles)
    for h=handles
        if~strcmp(get_param(h,'FontName'),cbinfo.EventData)
            set_param(h,'FontName',cbinfo.EventData);
        end
    end
end

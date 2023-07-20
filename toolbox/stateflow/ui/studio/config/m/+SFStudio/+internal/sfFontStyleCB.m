



function sfFontStyleCB(userdata,cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    if strcmp(userdata,'latex')
        undoId='Simulink:studio:LatexModeCommand';
    else
        undoId='simulink_ui:studio:resources:setFontStyleUndo';
    end
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setFontStyle,{userdata,cbinfo});
end

function loc_setFontStyle(command,cbinfo)
    switch command
    case 'bold'
        if cbinfo.EventData
            value='Bold';
        else
            value='Normal';
        end
    case 'italic'
        if cbinfo.EventData
            value='Italic';
        else
            value='Normal';
        end
    case 'latex'
        if cbinfo.EventData
            value=StateflowDI.NoteInterpretMode.Tex;
        else
            value=StateflowDI.NoteInterpretMode.Off;
        end
    otherwise
        error('Bad option passed to sfFontStyleCB');
    end

    selection=cbinfo.selection;
    for j=1:selection.size

        obj=selection.at(j);
        if~isempty(obj)&&~isa(obj,'StateflowDI.Junction')
            switch command
            case 'bold'
                if~strcmp(obj.font.Weight,value)
                    m=M3I.ImmutableModel.cast(obj.modelM3I.getRootDeviant);
                    obj=obj.asDeviant(m);
                    obj.font.Weight=value;
                end
            case 'italic'
                if~strcmp(obj.font.Style,value)
                    m=M3I.ImmutableModel.cast(obj.modelM3I.getRootDeviant);
                    obj=obj.asDeviant(m);
                    obj.font.Style=value;
                end
            case 'latex'
                if isa(obj,'StateflowDI.State')&&obj.isNote
                    if obj.noteInterpretMode~=value
                        m=M3I.ImmutableModel.cast(obj.modelM3I.getRootDeviant);
                        obj=obj.asDeviant(m);
                        obj.noteInterpretMode=value;
                    end
                end
            end
        end
    end
end





function sfFontSizeCB(userdata,cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    undoId='Stateflow:studio:SetFontSizeUndo';
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setFontSize,{userdata,cbinfo});
end

function loc_setFontSize(command,cbinfo)
    sizeList=[6,7,8,9,10,11,12,14,16,18,20,22,24,26,28,36,48,72];

    selection=cbinfo.selection;
    for j=1:selection.size
        obj=selection.at(j);
        if obj.isvalid&&~isa(obj,'StateflowDI.Junction')
            size=obj.font.Size;
            switch command
            case 'grow'
                bigger=sizeList(sizeList>size);
                if~isempty(bigger)
                    size=bigger(1);
                end
            case 'shrink'
                smaller=sizeList(sizeList<size);
                if~isempty(smaller)
                    size=smaller(length(smaller));
                end
            case 'select'
                size=str2double(cbinfo.EventData);
            otherwise
                error('Bad option passed to sfFontSizeCB');
            end

            if size>0&&size~=obj.font.Size
                m=M3I.ImmutableModel.cast(obj.modelM3I.getRootDeviant);
                obj=obj.asDeviant(m);
                obj.font.Size=size;
            end
        end
    end
end

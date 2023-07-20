



function junctionSizeCB(userdata,cbinfo)

    editor=cbinfo.studio.App.getActiveEditor;
    undoId='Stateflow:studio:SetJunctionSizeUndo';
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setJunctionSize,{userdata,cbinfo});
end

function loc_setJunctionSize(command,cbinfo)
    sizeList=[4,6,7,8,9,10,12,14,16,20,24,32,40,48,50];

    selection=cbinfo.selection;
    for j=1:selection.size
        obj=selection.at(j);
        if~isempty(obj)&&(isa(obj,'StateflowDI.Junction')||isa(obj,'StateflowDI.Port'))
            size=obj.size(1);
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
                error('Bad option passed to junctionSizeCB');
            end

            if size>0&&size~=obj.size(1)
                m=M3I.ImmutableModel.cast(obj.modelM3I.getRootDeviant);
                obj=obj.asDeviant(m);



                obj.radius=0.5*size;
            end
        end
    end
end

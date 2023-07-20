



function fontSizeCB(userdata,cbinfo)

    parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);
    handles=unique([parts.blocks,parts.notes,loc_uniqueLines(parts.segments)]);


    editor=cbinfo.studio.App.getActiveEditor;
    undoId='simulink_ui:studio:resources:setFontSizeUndo';
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setFontSize,{userdata,cbinfo,handles});
end

function loc_setFontSize(command,cbinfo,handles)
    sizeList=[6,7,8,9,10,11,12,14,16,18,20,22,24,26,28,36,48,72];

    for h=handles
        oldSize=get_param(h,'FontSize');
        newSize=oldSize;
        switch command
        case 'grow'
            oldSize=loc_convertDefaultSize(h,cbinfo.model.handle,oldSize);
            bigger=sizeList(sizeList>oldSize);
            if~isempty(bigger)
                newSize=bigger(1);
            end
        case 'shrink'
            oldSize=loc_convertDefaultSize(h,cbinfo.model.handle,oldSize);
            smaller=sizeList(sizeList<oldSize);
            if~isempty(smaller)
                newSize=smaller(length(smaller));
            end
        case 'select'
            newSize=str2double(cbinfo.EventData);
        otherwise
            error('Bad option passed to fontSizeCB');
        end

        if newSize>0&&newSize~=oldSize
            set_param(h,'FontSize',newSize);
        end
    end
end

function handles=loc_uniqueLines(segments)

    for j=1:length(segments)
        h=segments(j);
        parent=get_param(h,'LineParent');
        while parent~=-1
            h=parent;
            parent=get_param(h,'LineParent');
        end
        segments(j)=h;
    end


    handles=unique(segments);
end

function size=loc_convertDefaultSize(obj,model,oldSize)
    size=oldSize;
    if size<0
        switch get_param(obj,'Type')
        case 'block'
            size=get_param(model,'DefaultBlockFontSize');
        case 'line'
            size=get_param(model,'DefaultLineFontSize');
        case 'annotation'
            size=get_param(model,'DefaultAnnotationFontSize');
        otherwise
            error('Bad object type in fontSizeCB');
        end
    end
end

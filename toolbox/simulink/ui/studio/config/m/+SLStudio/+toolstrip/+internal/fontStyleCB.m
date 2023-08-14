



function fontStyleCB(userdata,cbinfo)

    parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);
    if strcmp(userdata,'latex')
        handles=parts.notes;
        undoId='Simulink:studio:LatexModeCommand';
    else
        handles=unique([parts.blocks,parts.notes,parts.segments]);
        undoId='simulink_ui:studio:resources:setFontStyleUndo';
    end


    editor=cbinfo.studio.App.getActiveEditor;
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_setFontStyle,{userdata,cbinfo,handles});
end

function ret=loc_getNewFontStyle(handles,param,onValue,offValue)
    for h=handles
        oldValue=get_param(h,param);

        if strcmp(oldValue,offValue)
            ret=onValue;
            return;
        end
    end

    ret=offValue;
end

function loc_setFontStyle(command,cbinfo,handles)
    hasEventData=true;

    if isempty(cbinfo.EventData)
        hasEventData=false;
    end

    s.bold=struct('param','FontWeight','on','bold','off','normal');
    s.italic=struct('param','FontAngle','on','italic','off','normal');
    s.latex=struct('param','TexMode','on','on','off','off');

    if(~isfield(s,command))
        error('Bad option passed to fontStyleCB');
    end

    options=s.(command);
    param=options.param;

    if hasEventData
        value=options.off;

        if cbinfo.EventData
            value=options.on;
        end
    else
        value=loc_getNewFontStyle(handles,param,options.on,options.off);
    end

    for h=handles
        if~strcmp(get_param(h,param),value)
            set_param(h,param,value);
        end
    end
end
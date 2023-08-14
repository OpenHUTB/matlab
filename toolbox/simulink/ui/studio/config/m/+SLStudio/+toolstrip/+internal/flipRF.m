



function flipRF(userdata,cbinfo,action)
    action.enabled=false;

    editor=cbinfo.studio.App.getActiveEditor;
    selections=editor.getSelection;

    if Simulink.internal.isArchitectureModel(cbinfo)

        return;
    end

    blocks=SLStudio.Utils.getSelectedBlockHandles(cbinfo);

    if selections.size()>1
        isOrientationLR=true;
    else
        orientation=get_param(blocks,'orientation');
        isOrientationLR=strcmpi(orientation,'right')|strcmpi(orientation,'left');
    end

    if isOrientationLR
        if~isempty(blocks)

            if strcmp(userdata,'left-right')
                action.enabled=true;
                return;
            end


            for block=blocks
                portRotationType=get_param(block,'PortRotationType');
                if strcmpi('physical',portRotationType)
                    action.enabled=true;
                    return;
                end
            end
        end
    else
        if~isempty(blocks)

            if strcmp(userdata,'up-down')
                action.enabled=true;
                return;
            end


            for block=blocks
                portRotationType=get_param(block,'PortRotationType');
                if strcmpi('physical',portRotationType)
                    action.enabled=true;
                    return;
                end
            end
        end
    end

    notes=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    for j=1:length(notes)

        note=get_param(notes(j),'Object');
        filename=getResolvedResourceFile(cbinfo.model.handle,note.imagePath);
        if~isempty(filename)
            action.enabled=true;
            return;
        end
    end
end

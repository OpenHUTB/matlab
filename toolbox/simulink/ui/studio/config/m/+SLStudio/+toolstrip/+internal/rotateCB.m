



function rotateCB(userdata,cbinfo)
    if SLStudio.DiagramMenu('UseGroup',cbinfo)
        cbinfo.userdata=['group-',userdata];
        SLStudio.DiagramMenu('RotateGroupCB',cbinfo);
    else
        isImage=loc_isImage(cbinfo);
        if isImage
            if strcmpi(userdata,'clockwise')
                cbinfo.userdata='RotateRight90';
            else
                cbinfo.userdata='RotateLeft90';
            end
            SLStudio.DiagramMenu('RotateImageCB',cbinfo);
        else
            if SLStudio.Utils.isWebBlockInPanel(cbinfo)



                editor=cbinfo.studio.App.getActiveEditor();
                if~SLM3I.SLDomain.getPanelEditModeForEditor(editor)
                    notificationTag='simulink_ui:webblocks:resources:OrientationChangeDisabledOutsidePEM';
                    notification=message(notificationTag).getString();
                    editor.deliverInfoNotification(notificationTag,notification);
                    return;
                end


                block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
                orientations={'Right','Down','Left','Up'};
                currentOrientation=get_param(block.handle,'Orientation');
                currentOrientationIndex=find(strcmpi(orientations,currentOrientation));
                if strcmp(userdata,'clockwise')
                    newOrientationIndex=mod(currentOrientationIndex,4)+1;
                else
                    newOrientationIndex=mod(currentOrientationIndex+2,4)+1;
                end
                update.Orientation=orientations{newOrientationIndex};
                SLM3I.SLDomain.notifyWebContentOfParamUpdate(block.handle,'DashboardBlockOrientation',jsonencode(update),'undoable');
                return;
            end
            cbinfo.userdata=userdata;
            SLStudio.DiagramMenu('RotateBlocksCB',cbinfo);
        end
    end
end

function isImage=loc_isImage(cbinfo)
    noteHandles=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    isImage=false;
    if~isempty(noteHandles)
        note=get_param(noteHandles(1),'Object');
        filename=getResolvedResourceFile(cbinfo.model.handle,note.imagePath);
        if(~isempty(filename))
            isImage=true;
        end
    end
end
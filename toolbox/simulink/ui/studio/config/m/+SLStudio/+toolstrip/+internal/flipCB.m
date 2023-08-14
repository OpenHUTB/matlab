



function flipCB(userdata,cbinfo)

    undoId='Simulink:studio:FlipBlocksCommand';
    editor=cbinfo.studio.App.getActiveEditor;
    editor.createMCommand(undoId,DAStudio.message(undoId),@loc_flip,{userdata,cbinfo});
end

function loc_flip(flipDirection,cbinfo)

    blocks=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
    isPortTypePhysical=false;

    if~isempty(blocks)
        if length(blocks)>1
            isOrientationLR=true;
        else
            orientation=get_param(blocks,'orientation');
            isOrientationLR=strcmpi(orientation,'right')|strcmpi(orientation,'left');
            isPortTypePhysical=strcmp(get_param(blocks,'PortRotationType'),'physical');
        end

        if isPortTypePhysical||isOrientationLR
            blockFlipDirection=flipDirection;
        else
            if strcmpi(flipDirection,'left-right')
                blockFlipDirection='up-down';
            else
                blockFlipDirection='left-right';
            end
        end


        if strcmp(blockFlipDirection,'up-down')
            for block=blocks
                portRotationType=get_param(block,'PortRotationType');
                if strcmpi('physical',portRotationType)
                    flip_blocks(block,'up-down');
                end
            end
        else
            if length(blocks)==1
                flip_blocks(blocks(1));
            else
                areas=SLStudio.Utils.getSelectedAreaAnnotationHandles(cbinfo);
                flip_group(blocks,'group-left-right',areas);
            end
        end
    end


    if strcmp(flipDirection,'left-right')
        flipDirection='FlipHorizontal';
    else
        flipDirection='FlipVertical';
    end


    notes=SLStudio.Utils.getSelectedAnnotationHandles(cbinfo);
    for j=1:length(notes)
        note=get_param(notes(j),'Object');
        filename=getResolvedResourceFile(cbinfo.model.handle,note.imagePath);
        if~isempty(filename)
            filename=GLUE2.Util.imageRotate(filename,flipDirection);
            note.setImage(filename);
        end
    end
end

function h=thumbnail





    h=Simulink.slx.PartHandler('Thumbnail','',[],@i_save);
end

function name=i_partname(saveOptions)


    if strcmp(saveOptions.getPartNamePrefix,'/simulink/')
        name='/metadata/thumbnail.png';
    else
        name=[saveOptions.getPartNamePrefix,'thumbnail.png'];
    end
end

function id=i_id(modelHandle)


    if Simulink.harness.isHarnessBD(modelHandle)
        id=['Thumbnail_',get_param(modelHandle,'HarnessID')];
    else
        id='Thumbnail';
    end
end

function i_save(modelHandle,saveOptions)
    partName=i_partname(saveOptions);

    writer=saveOptions.writerHandle;

    if saveOptions.isAutosave









        writer.deletePart(partName);
        return;
    end

    if~saveOptions.isSLX

        writer.deletePart(partName);
        return;
    end

    if strcmp(get_param(0,'SaveSLXThumbnail'),'off')


        writer.deletePart(partName);
        return;
    end




    if~Simulink.slx.isPartDirty(modelHandle,'thumbnail')&&writer.hasPart(partName)

        return;
    end
    thumbnailfile=Simulink.slx.getUnpackedFileNameForPart(modelHandle,partName);


    slCreateThumbnailImage(modelHandle,thumbnailfile);
    if exist(thumbnailfile,'file')
        part_info=Simulink.loadsave.SLXPartDefinition(...
        partName,...
        '',...
        'image/png',...
        'http://schemas.openxmlformats.org/package/2006/relationships/metadata/thumbnail',...
        i_id(modelHandle));
        writer.writePartFromFile(part_info,thumbnailfile);
    else
        writer.deletePart(partName);
    end
end




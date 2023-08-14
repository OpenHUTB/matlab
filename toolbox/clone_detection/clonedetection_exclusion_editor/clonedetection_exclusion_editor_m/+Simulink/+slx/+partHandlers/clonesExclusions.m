function output=clonesExclusions




    output=Simulink.slx.PartHandler(i_id,'blockDiagram',[],@i_save);

end

function id=i_id
    id='ClonesExclusions';
end

function name=i_partname
    name='/advisor/clonesExclusions.xml';
end

function p=i_clones_partinfo
    p=Simulink.loadsave.SLXPartDefinition(i_partname,...
    '/simulink/blockdiagram.xml',...
    'application/vnd.mathworks.simulink.advisor+xml',...
    'http://schemas.mathworks.com/simulink/2015/relationships/Advisor',...
    i_id);
end

function i_save(modelHandle,saveOptions)

    if Simulink.harness.isHarnessBD(modelHandle)
        return;
    end

    modelName=get_param(modelHandle,'Name');
    instance=CloneDetector.ExclusionEditorUIService.getInstance;
    isAvailable=instance.isExclusionEditorAvailable(modelName);

    if isAvailable
        exclusionEditorWindow=CloneDetector.getExclusionEditor(modelName);
        controller=exclusionEditorWindow.Controller;
        externalFilePath=controller.getExternalFilePath();
        if isempty(externalFilePath)
            filters_file=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
            if~exist(filters_file,'file')
                return
            end
            saveOptions.writerHandle.writePartFromFile(i_clones_partinfo,filters_file);
        end
    end
end


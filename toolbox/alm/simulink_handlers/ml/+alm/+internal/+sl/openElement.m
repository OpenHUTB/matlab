function openElement(absoluteFilePath,artifact,blockDiagramName)





    if bdIsLoaded(blockDiagramName)
        throwIfDifferentSource(blockDiagramName,absoluteFilePath);
    else



        load_system(absoluteFilePath);

        [~,ownerBDName]=fileparts(absoluteFilePath);

        throwIfDifferentSource(ownerBDName,absoluteFilePath);

        if~strcmp(ownerBDName,blockDiagramName)
            harnessMetaData=Simulink.harness.find(ownerBDName,"Name",blockDiagramName);
            if numel(harnessMetaData)==1
                Simulink.harness.load(harnessMetaData.ownerFullPath,harnessMetaData.name);
            else
                error(message("alm:simulink_handlers:OpenError",...
                alm.internal.createAddressString(artifact)));
            end
        end
    end







    bdTypes=[...
    "sl_block_diagram",...
    "sl_harness_block_diagram"];

    refTypes=[...
    "sl_ref",...
    "sl_model_reference",...
    "sl_subsystem_reference",...
    "sl_harness_cut"];

    if any(bdTypes==artifact.Type)
        open_system(blockDiagramName);

    elseif any(refTypes==artifact.Type)
        open_system(blockDiagramName);

        sid=blockDiagramName+":"+artifact.Address;
        Simulink.ID.hilite(sid);
        set_param(sid,"Selected","on");

    else
        open_system(blockDiagramName);
        open_system(blockDiagramName+":"+artifact.Address,"force");
    end

end

function throwIfDifferentSource(blockDiagramName,absoluteSourceFilePath)
    if~strcmp(get_param(blockDiagramName,"FileName"),absoluteSourceFilePath)
        error(message("alm:simulink_handlers:ModelWithSameNameAlreadyLoaded",...
        blockDiagramName,alm.internal.createRevealFileHyperlink(absoluteSourceFilePath)));
    end
end

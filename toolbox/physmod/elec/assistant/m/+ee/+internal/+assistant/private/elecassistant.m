function importedStatus=elecassistant(fileName,importedFileName)




    importedStatus=assistant_private(fileName,importedFileName);

    disp(['Import completed: ',fileName]);
end

function importStatus=assistant_private(fileName,importedFileName)

    [~,modelName,~]=fileparts(fileName);
    [~,newModelName,~]=fileparts(importedFileName);



    powerguiBlocks=find_system(modelName,'LookUnderMasks','functional',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on',...
    'MaskType','PSB option menu block');

    if~isempty(powerguiBlocks)
        powerguiName=powerguiBlocks{1};
        rb=get_param(powerguiName,'ReferenceBlock');



        if isempty(rb)
            rb=get_param(powerguiName,'AncestorBlock');
        else
            set_param(powerguiName,'ReferenceBlock','','AncestorBlock',rb);
        end
        set_param(powerguiName,'AncestorBlock','','ReferenceBlock',rb);
    end

    if exist(importedFileName,'file')
        disp("The imported file already exists, overwriting the existing file.");
    end
    copyfile(fileName,importedFileName,'f');

    ee.internal.assistant.utils.togglePath('on');
    clear ElecAssistantLog;
    w=warning('off');
    open_system(importedFileName,'force');
    warning(w);
    try
        w=warning('off');
        fileattrib(importedFileName,'+w');
        save_system(importedFileName);
        close_system(importedFileName);
        warning(w);
    catch
        importStatus=0;
        warning('Import failed.');
        ee.internal.assistant.utils.togglePath('off');
        warning(w);
        return
    end
    logObj=ElecAssistantLog.getInstance();
    logObj.genImportStatus();

    ee.internal.assistant.utils.togglePath('off');
    importStatus=1;


    open_system(importedFileName);

    switch get_param(newModelName,'BlockDiagramType')
    case 'model'
        set_param(newModelName,'Solver','ode23t');


        physicalNetworks=ee.internal.assistant.utils.findPhysicalNetwork(newModelName);


        try
            unconnectedSolvers=ee.internal.assistant.utils.connectSolverConfig(newModelName,physicalNetworks);
            ee.internal.assistant.utils.removeUnconnectedSolverConfiguration(unconnectedSolvers);
        catch
            warning('physmod:ee:assistant:ConnectingSCFailed','Connecting solver configuration to the networks failed.');
        end


        try
            ee.internal.assistant.utils.connectElecRef(physicalNetworks);
        catch
            warning('physmod:ee:assistant:ConnectingERFailed','Connecting electrical reference to the networks failed.');
        end


        set_param(newModelName,'SimscapeNominalValues',simscape.nominal.internal.getDefaultNominalValues);
    case 'library'
        set_param(newModelName,'Lock','off');
    otherwise
        error('physmod:ee:assistant:UnknownBlockDiagramType','Model %s has unknown BlockDiagramType.',newModelName,get_param(newModelName,'BlockDiagramType'));
    end

    set_param(newModelName,'SaveWithParameterizedLinksMsg','none');
    save_system(importedFileName);
    close_system(importedFileName);
end


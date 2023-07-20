function saveCurrentToResetModel(mdl,section,task,status_file_location)




    lessonString=strrep(num2str(section),'.','_');


    if logical(section)
        reset_name=['Section',num2str(lessonString),'TaskResets'];
    else
        reset_name=[mdl,'_reset_copy'];
    end

    if~exist(status_file_location,'dir')
        mkdir(status_file_location);
    end

    if~exist(fullfile(status_file_location,[reset_name,'.slx']),'file')
        load_system(new_system(reset_name));
    else
        load_system(fullfile(status_file_location,reset_name));
    end

    save_system(fullfile(status_file_location,[reset_name,'.slx']),'SaveDirtyReferencedModels','on');




    reset_subsys=find_system(reset_name,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name',['Task',num2str(task),'Reset']);

    if isempty(reset_subsys)


        try
            add_block('built-in/Subsystem',[reset_name,'/Task',num2str(task),'Reset']);


            existing_graders=find_system(mdl,'MatchFilter',...
            @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on','ReferenceBlock','signalChecks');
            for idx=1:numel(existing_graders)
                set_param(existing_graders{idx},'PreCopyFcn','');
            end

            Simulink.BlockDiagram.copyContentsToSubsystem(mdl,[reset_name,'/Task',num2str(task),'Reset']);





            for idx=1:numel(existing_graders)
                set_param(existing_graders{idx},'PreCopyFcn',...
                "error(message('learning:simulink:resources:ErrorNoCopy').getString())");
            end
        catch
            error(message('learning:simulink:resources:ErrorCannotReset'));
        end
    end

    close_system(fullfile(status_file_location,reset_name),1);
end

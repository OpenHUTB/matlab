classdef ScenarioTopics<handle




    properties(GetAccess='public',SetAccess='private')
        BASE_MSG='/sta';
        START_UP='startup';
        START_UP_DONE='startup_done';
        IS_UI_DIRTY='isuidirty';
        NEW='new';
        OPEN='open';
        DO_SAVE='dosave';
        DELETE='deletesignal';
        CONNECTOR_ONUIMODEL='SignalAuthoring/UIModelData';
        SCENARIO_MAP_RESULTS='scenariomappingresults';
        LAUNCH_EDITOR='launcheditor';
        LAUNCH_EDITOR_BLANK='launcheditor_blank';
        DIAGNOSTICS_DLG='sta/mainui/diagnostic/request';
        SIM_STATE_ACTIVE='sta/modelsimstateactive';
        FAST_RESTART_ISON='sta/fastRestartIsOn';
        MODEL_TO_USE='sta/modeltouse';


        SCENARIO_CREATE='sta/scenario/create';
        SCENARIO_SAVE='sta/scenario/savetomldatx';

        CREATE_EXTERNAL_INPUTS='sta/scenario/externalsources/create';





        SCENARIO_CREATE_MLDATX='sta/scenario/create/mldatx';
        SCENARIO_MAPPING_STARTED='sta/scenario/mapping/start';
        SCENARIO_MAPPING_COMPLETED='sta/scenario/mapping/complete';
        SCENARIO_SESSION_MAPPING_RESTORE='SignalAuthoring/mapping/restoremapping';
        SCENARIO_SESSION_OPENING='sta/scenario/open/inprogress';

        UNSAVED_ONCLOSE='handleUnsavedChangesDialog';
        SAVE_FROM_CLOSE='saveonclose';
        DIALOG_BOX='displayMsgBox';
        FORCE_CLOSE='forceclose';

        TIME_OF_MAP='timeofmapping';

        CLEAR_CONNECTIONS='clearconnections';

        MATLAB_EXIT_CALLED='matlabexit';
        FORCE_MATLAB_EXIT='forceexit';

        RE_ASSIGN_MAPPING='reassignmap';
        SCENARIO_SDI_RUN_MAP='scenario_to_run_map';
        SET_RUNID='set_runid';
        BRING_TO_FRONT='bringtofront';
        UPDATE_TREE_ORDER='update_tree_order';

        GET_PREFS='getpreferences';
        SET_PREFS='setpreferences';
    end

    methods
    end

end



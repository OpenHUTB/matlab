classdef EditorTopics<handle





    properties(GetAccess='public',SetAccess='private')
        BASE_MSG='/staeditor';
        START_UP='startup';
        START_UP_DONE='startup_done';
        ID_TO_REPORT='idtoreport';
        IS_UI_DIRTY='isuidirty';
        IS_EDIT_MODE='iseditmode';
        CONNECT='connecttoupstream';
        SIGNAL_EDIT='signaledit';
        NEW='new';
        OPEN='open';
        DO_SAVE='dosave';
        EDITOR_UPDATED='editorupdated';
        DELETE='deletesignal';
        CONNECTOR_ONUIMODEL='SignalAuthoring/UIModelData';
        DIAGNOSTICS_DLG='sta/mainui/diagnostic/request';
        UNSAVED_ONCLOSE='handleUnsavedChangesDialog';
        SAVE_FROM_CLOSE='saveonclose';
        FORCE_CLOSE='forceclose';
        DIALOG_BOX='displayMsgBox';
        MAT_FILE_UPDATE='updatematfile';
        ITEM_PROP_UPDATE='item/propertyupdate';
        MODEL_TO_USE='sta/modeltouse';

        SET_UI_TITLE='signaleditor/ui/updatetitle';

        SIGNAL_INSERT='insertsignal';
        SIGNAL_PASTE='insertpaste';
        REMOVE_SIGNAL_AND_DESCENDANTS='removesignalanddescendants';

        MARK_SIGNAL_NAME_EDIT='marksignalfornameedit'

        SPINNER='spinner';
        MOVE_ITEM='moveitem';
        LAUNCH_HELP='launchhelp';

        MATLAB_EXIT_CALLED='matlabexit';
        FORCE_MATLAB_EXIT='forceexit';
        RE_ASSIGN_MAPPING='reassignmap';

        SCENARIO_SDI_RUN_MAP='scenario_to_run_map';
        SET_RUNID='set_runid';
        REPLACE_OLD_ID='replaceid';

        UPDATE_WORKING_ID='update_working_id';
        BRING_TO_FRONT='bringtofront';
        IS_UI_CONNECTING='is_ui_connecting';
        UNLINK_FILE='unlink/file';

        FORCE_DIRTY='startup/force_dirty';
        AUTHOR_INSERT='author/insert';
        RE_AUTHOR_INSERT='reauthor';

        ROLL_BACK_WORK_AREA_ACTION='editarea/rollbackaction';
    end

    methods
    end

end



function cb_help(which_help)



    ui_help_anchor='';

    switch lower(which_help)
    case 'preview'
        ui_help_anchor='ROOTINPORT_VIEWER';
    case 'ds_plot'
        ui_help_anchor='ROOTINPORT_VIEWER';
    case 'editor'
        ui_help_anchor='insert_and_edit_gui';
    case 'insertsignal'
        ui_help_anchor='insert_and_edit_default_properties';
    case 'standalone_editor'
        ui_help_anchor='STANDALONE_SIGNALEDITOR';
    case 'signaleditor_author'
        ui_help_anchor='signaleditor_author';
    case 'signaleditor_author_reauthor'
        ui_help_anchor='signaleditor_author_reauthor';
    case 'signaleditor_freehand'
        ui_help_anchor='signaleditor_freehand';
    end

    helpview(fullfile(docroot,'simulink','helptargets.map'),ui_help_anchor);